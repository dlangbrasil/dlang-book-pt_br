/**
 * This program processes a Ddoc file to scrape the code examples and compile
 * them. Here are the rules of the game:
 *
 * o Code samples that do not have a main() are ignored.
 *
 * o Code samples that have $(CODE_ADD_MAIN) receive an empty main().
 *
 * o Code samples that import non-standard modules are ignored.
 *
 * o Code samples that have a main() but should not be compiled must be marked
 *   with $(CODE_DONT_TEST) e.g. as 'void $(CODE_DONT_TEST)main()'.
 *
 * o Certain lines of code can be commented-out in code compilation testing by
 *   $(CODE_COMMENT_OUT)
 *
 * o Any code sample can be named by $(CODE_NAME).
 *
 * o Code samples that are named by $(CODE_NAME) can be imported by other code
 *   samples by $(CODE_XREF).
 *
 * o Code samples that have $(DERLEME_HATASI) ("compilation error" in English)
 *   are expected to fail compilation. Others are expected to succeed
 *   compilation.
 */

import std.stdio;
import std.string;
import std.regex;
import std.process;
import std.algorithm;
import std.array;
import std.exception;
import std.file;
import std.path;

enum TestResult { passed, failed, noTestRun }

struct TestOutcome
{
    TestResult result;
    string output;
    string input;
}

struct FileStatus
{
    TestResult lastTestResult;
    size_t totalPrograms;    // The number of sample programs actually
                             // compiled
}

/* This is for correct grammar in the test reports. */
string pluralFor(size_t n)
{
    return n == 1 ? "" : "s";
}

int main(string[] args)
{
    auto file = args[1];
    auto sourceDir = args[2];
    auto targetDir = args[3];
    const alphabetName = args[4];    /* "english", "turkish", etc. */

    auto codeCompiler = environment["CODE_COMPILER"];
    writefln("Using %s to compile code samples", codeCompiler);

    const FileStatus status =
        testCodes(codeCompiler, file, sourceDir, targetDir, alphabetName);

    final switch (status.lastTestResult) {
    case TestResult.passed:
        writefln("Compiled %s program%s",
                 status.totalPrograms, pluralFor(status.totalPrograms));
        break;

    case TestResult.failed:
        writeln("Failed");
        return 1;

    case TestResult.noTestRun:
        writeln("Nothing to test; skipped");
        break;
    }

    return 0;
}

/* Represents a scraped code section. */
struct CodeSection
{
    string name;
    size_t lineNumber;
    string[] lines;
    bool hasMain = false;
    bool hasNonStandardImport = false;
    bool expectedToFail = false;
    bool importsStdStdio;
    bool usesStdStdio;

    @property bool isStripped() const
    {
        return (lines.empty || (!lines.front.strip.empty &&
                                !lines.back.strip.empty));
    }
}

/* Renames main() presumably to move it out of the way of the actual
 * main(). */
auto main_renamed(const(string[]) lines)
{
    return lines.map!(line => line.replace(" main(", " RENAMED_main("));
}

CodeSection extractCodeSection(R)(ref R range,
                                  string fileName,
                                  ref size_t lineNumber,
                                  CodeSection[string] codeSections)
{
    /* Skip the opening code delimiter. */
    range.popFront();
    ++lineNumber;

    CodeSection result;

    while (true) {
        auto line = range.front;

        if (line.isCodeDelimiter) {
            /* This section ends here. Skip the closing code delimiter. */
            range.popFront();
            ++lineNumber;
            break;
        }

        // Use a do-while loop so that we catch leading and trailing empty lines
        do {
            line = processCodeLine(line, fileName, lineNumber,
                                   codeSections, result);
        } while (!line.empty);

        ++lineNumber;
        range.popFront();

        if (range.empty) {
            break;
        }
    }

    enforceWithContext(
        result.isStripped,
        format("Code section has leading or trailing empty lines: %-(%s\n%)",
               result.lines),
        fileName, lineNumber);

    result.lineNumber = lineNumber;

    return result;
}

void enforceWithContext(bool condition,
                        string message,
                        string fileName,
                        size_t lineNumber)
{
    if (!condition) {
        writefln("Error: %s:%s: %s", fileName, lineNumber, message);
        throw new Exception("Enforcement failed");
    }
}

/* Processes code lines by parsing CODE_NAME, expanding CODE_XREF, etc. */
char[] processCodeLine(char[] line,
                       string fileName,
                       size_t lineNumber,
                       CodeSection[string] codeSections,
                       ref CodeSection result)
{
    auto addMainResult = line.findSplit("$(CODE_ADD_MAIN)");
    if (!addMainResult[1].empty) {
        result.hasMain = true;    // main() will later be added by a ddoc macro
    }

    auto codeNameResult = line.findSplit("$(CODE_NAME ");

    if (!codeNameResult[1].empty) {
        /* This line introduces the name of this section. */

        enforceWithContext(result.name.empty,
                           "Multiple CODE_NAME tags", fileName, lineNumber);

        const closingParenResult = codeNameResult[2].findSplit(")");

        result.name = closingParenResult[0].strip.idup;

        enforceWithContext(
            !closingParenResult[2].empty,
            format("Rest of CODE_NAME line is empty: %s", line),
            fileName, lineNumber);

        line = closingParenResult[2].dup;

    } else {

        const codeInsertResult = line.findSplit("$(CODE_XREF ");

        if (!codeInsertResult[1].empty) {
            /* This line cross-references another code section. */

            const closingParenResult =
                codeInsertResult[2].findSplit(")");

            const codeRef = closingParenResult[0].strip;

            enforceWithContext((codeRef in codeSections) !is null,
                               format("Undefined code section: %s", codeRef),
                               fileName, lineNumber);

            enforceWithContext(!closingParenResult[2].empty,
                               "CODE_XREF cannot be the last tag on a line",
                               fileName, lineNumber);

            // There may be other CODE_XREF on this line
            line = closingParenResult[2].dup;

            /* Insert the referenced code section after renaming its
             * main() function so that it doesn't conflict with the actual
             * main of this sample program. */
            result.lines ~= main_renamed(codeSections[codeRef].lines).array;

            if (codeSections[codeRef].usesStdStdio) {
                result.usesStdStdio = true;
            }

        } else {
            /* This is not a code cross-reference. */

            const commentOutResult = line.findSplit("$(CODE_COMMENT_OUT");

            if (!commentOutResult[1].empty) {
                /* This line should be ignored. */

            } else {
                /* This is an ordinary code line. */

                result.lines ~= line.dup;

                enum stdStdioExp = ctRegex!("^import std.stdio;");

                if (matchFirst(line, stdStdioExp)) {
                    result.importsStdStdio = true;
                }

                enum stdStdioUseExp = ctRegex!("(writeln|writefln|File)");

                if (matchFirst(line, stdStdioUseExp)) {
                    result.usesStdStdio = true;
                }

                enum mainLineExpr = ctRegex!("(void|int) main[ ]*(.*)");

                if (matchFirst(line, mainLineExpr)) {
                    /* Ok, this section has a main() function. */
                    result.hasMain = true;
                }

                enum importLineExpr = ctRegex!(`.*import *([^(]*?)(\..*)*;`);
                line = line.replace("$(HILITE", "");
                auto importMatch = matchFirst(line, importLineExpr);

                if (!importMatch.empty) {
                    const packageName = importMatch[1];

                    if (!["std", "core"].canFind(packageName)) {
                        /* This section has a non-standard import. */
                        result.hasNonStandardImport = true;
                    }
                }

                enum compFailureExpr = ctRegex!(`.*DERLEME_HATASI`);

                if (matchFirst(line, compFailureExpr)) {
                    /* This section is expected to fail. */
                    result.expectedToFail = true;
                }
            }

            line = [];
        }
    }

    return line;
}

/* Whether this is a Ddoc code section delimiter. */
bool isCodeDelimiter(const(char)[] line)
{
    return line == "---";
}

/* Tests the sample codes of the provided Ddoc file. */
FileStatus testCodes(string codeCompiler,
                     string fileName,
                     string sourceDir,
                     string targetDir,
                     string alphabetName)
{
    const sourceFileName = buildPath(sourceDir, fileName);
    auto file = File(sourceFileName, "r");

    CodeSection[string] codeSections;
    size_t testCount = 0;
    size_t lineNumber = 1;

    char[][] range;

    /* We could not use byLine due to a dmd bug where byLine would write
     * out-of-bounds. Instead, we read the file eagerly. */
    while (true) {
        import std.conv;
        string line = file.readln.stripRight;
        if (file.eof) {
            break;
        }

        range ~= line.to!(char[]);
    }

    size_t programCount = 1;

    while (!range.empty) {
        auto line = range.front;

        if (line.isCodeDelimiter) {
            auto codeSection =
                extractCodeSection(
                    range, sourceFileName, lineNumber, codeSections);

            if (codeSection.hasNonStandardImport) {
                writefln("Code has non-standard import; skipping");
                continue;
            }

            if (!codeSection.name.empty && codeSection.name !in codeSections) {
                codeSections[codeSection.name] = codeSection;
            }

            if (codeSection.hasMain) {
                const programName =
                    format("%s.%s.d", baseName(fileName, ".d"), programCount);

                const testOutcome = testProgram(
                    codeCompiler,
                    programName, targetDir, codeSection, alphabetName);
                ++programCount;

                const testResult = testOutcome.result;

                const goodOutcome = ((codeSection.expectedToFail &&
                                      (testResult == TestResult.failed))
                                     ||
                                     (!codeSection.expectedToFail &&
                                      (testResult == TestResult.passed)));

                if (!goodOutcome) {
                    writefln("Unexpected compilation outcome");
                    writefln("Result: %s", testOutcome.result);
                    writefln("Output:\n%s\n", testOutcome.output);
                    if (!testOutcome.input.empty) {
                        writefln("Input:\n%s", testOutcome.input);
                    }

                    writefln("Program:\n%-(%s\n%)", codeSection.lines);

                    writefln("Error: %s:%s:",
                             sourceFileName,
                             codeSection.lineNumber);

                    return FileStatus(TestResult.failed, testCount);
                }

                ++testCount;
            }
        }

        if (!range.empty) {
            ++lineNumber;
            range.popFront();
        }
    }

    return FileStatus(testCount ? TestResult.passed : TestResult.noTestRun,
                      testCount);
}

static const string[string] comments;
static this() {
    comments = [ "english" : "// ← compilation ERRORpp",
                 "turkish" : "// ← derleme HATASI",
                 "portuguese" : "// ← ERRO de compilação"];
}

static const string[string] notices;
static this() {
    notices = [ "english" : "NOTE: This program is expected to fail compilation.",
                "turkish" : "NOT: Bu program derleme hatasına neden olur.",
                "portuguese" : "NOTA: Espera-se que este programa falhe na compilação."];
}

/* Tests the provided program. */
TestOutcome testProgram(string codeCompiler,
                        string programName,
                        string targetDir,
                        CodeSection codeSection,
                        string alphabetName)
{
    const preFileName =
        buildPath(targetDir, format("%s.pre_ddoc.d", programName));
    auto postFileName =
        buildPath(targetDir, programName);

    if (alphabetName == "english") {
        postFileName = postFileName.replace(".cozum.", ".solution.");
    } else if (alphabetName == "turkish") {
        // Nothing to do
    } else if (alphabetName == "portuguese") {
        postFileName = postFileName.replace(".cozum.", ".solucao.");
    } else {
        throw new Exception("Unsupported alphabet: %s", alphabetName);
    }

    const compilationFailureComment = comments[alphabetName];

    /* We want to remove Ddoc markup from the code. */
    const ddocMacros = [
        "Macros:",
        "DDOC=$(BODY)",
        "DDOC_COMMENT=",
        "HILITE=$0",
        format("DERLEME_HATASI=%s", compilationFailureComment),
        "D_CODE=$0",
        "D_KEYWORD=$0",
        "D_STRING=$0",
        "D_COMMENT=$0",
        "RED=$0",
        "BLUE=$0",
        "GREEN=$0",
        "YELLOW=$0",
        "BLACK=$0",
        "WHITE=$0",
        "CODE_NOTE=// $0",
        "ESCAPES=/&/&/ /</</ />/>/",
        "CODE_ADD_MAIN=void main(){} ",
    ];

    /* Pre-process the file to remove all of the Ddoc markup from the sample
     * program. */

    auto preDdocFile = File(preFileName, "w");

    // The following space character is significant. It is a workaround to a peculiar <br><br> that otherwise appears in
    // the file.
    preDdocFile.writeln("Ddoc \n---");

    const compilationFailureNotice = notices[alphabetName];

    if (codeSection.expectedToFail) {
        preDdocFile.writefln("/* %s */\n", compilationFailureNotice);
    }

    const program = codeSection.lines;

    if (!program[0].canFind("module")) {
        const moduleName = baseName(postFileName, ".d").replace(".", "_");
        preDdocFile.writefln("module %s;\n", moduleName);
    }

    const missingStdStdio = (codeSection.usesStdStdio &&
                             !codeSection.importsStdStdio);

    if (missingStdStdio) {
        preDdocFile.writeln("import std.stdio;");
    }

    preDdocFile.writefln("%-(%s\n%)", program);
    preDdocFile.writeln("---");
    preDdocFile.writefln("%-(%s\n%)", ddocMacros);
    preDdocFile.close();

    const convertCommand = format("%s -Dd%s -Df%s %s",
                           codeCompiler, postFileName.dirName, postFileName, preFileName);
    writeln("Executing ", convertCommand);
    auto ddocResult = executeShell(convertCommand);
    
    if (ddocResult.status) {
        return TestOutcome(TestResult.failed,
                           ddocResult.output,
                           preFileName.readText);
    }

    removeLeadingTrailingEmptyLines(postFileName);
    remove(preFileName);
    
    const compileCommand = format("%s -J. -unittest -c -de -w -debug -o- %s",
                                  codeCompiler, postFileName);
    writeln("Executing ", compileCommand);
    auto compilationResult = executeShell(compileCommand);

    if (compilationResult.status) {
        return TestOutcome(TestResult.failed, compilationResult.output);
    }

    return TestOutcome(TestResult.passed);
}

void removeLeadingTrailingEmptyLines(string fileName)
{
    const outFileName = fileName ~ ".tmp";
    string[] buffer;

    auto isEmptyLine(E)(E line) {
        return strip(line).empty;
    }

    auto input = File(fileName, "r")
                 .byLineCopy
                 .array;

    while (!input.empty && isEmptyLine(input.front)) {
        input.popFront();
    }

    while (!input.empty && isEmptyLine(input.back)) {
        input.popBack();
    }

    auto output = File(outFileName, "w");

    foreach (line; input) {
        // Remove DOS line-endings
        output.writeln(line.filter!(c => c != '\r'));
    }

    remove(fileName);
    rename(outFileName, fileName);
}
