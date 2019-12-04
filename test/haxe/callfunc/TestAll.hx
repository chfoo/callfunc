package callfunc;

import utest.Runner;
import utest.ui.Report;

#if js
import callfunc.core.emscripten.EmContext;
#end


class TestAll {
    public static function main() {
        #if sys
        if (Sys.args().indexOf("--test-performance") >= 0) {
            trace("PerformanceTest");
            PerformanceTest.run();
        }
        #end

        #if js
        var context = new EmContext(Reflect.field(js.Browser.window, "Module"));
        Callfunc.setInstance(new Callfunc(context));

        js.Syntax.code("waitForLoad({0})", runTests);
        #else
        runTests();
        #end
    }

    static function runTests() {
        var runner = new Runner();

        #if sys
        runner.addCase(new callfunc.test.TestCairoMatrix());
        runner.addCase(new callfunc.test.TestCairoSurface());
        #end

        runner.addCase(new callfunc.test.TestDataView());
        runner.addCase(new callfunc.test.TestExamplelib());
        runner.addCase(new callfunc.test.TestCallfunc());
        runner.addCase(new callfunc.test.TestPointer());
        runner.addCase(new callfunc.test.TestStructAccess());
        Report.create(runner);
        runner.run();
    }
}
