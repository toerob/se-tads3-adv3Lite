#charset "us-ascii"
#include <tads.h>

class BeforeEach: object
    group = nil
    run() {
        throw new Exception('BeforeEach saknar implementation');
    }
;

class AfterEach: object
    group = nil
    run() {
        throw new Exception('AfterEach saknar implementation');
    }
;

class TestUnit: object
    group = nil
    skip = nil
    only = nil
    run() {
        throw new Exception('Test saknar implementation');
    }
;

/* assertEquals kvar för bakåtkompatibilitet — delegerar till assertThat */
function assertEquals(expected, receivedValue) {
    assertThat(receivedValue).isEqualTo(expected);
}

function assertThat(expressionOrValue) {
    return new Assertions().assertThatValueOrExpression(expressionOrValue);
}

class Assertions: object
    receivedValue = nil
    assertionIndex = 0

    assertThatValueOrExpression(val) {
        self.receivedValue = dataTypeXlat(val) == TypeFuncPtr ? val() : val;
        return self;
    }

    startsWith(expectedValue) {
        self.assertionIndex++;
        /*if(expectedValue == 'TODO') {
            tadsSay('\nTODO_VALUE[' + self.receivedValue + ']\n');
            return self;
        }*/
        if(!self.receivedValue.startsWith(expectedValue)) {
            reportFailure(expectedValue, self.receivedValue,
                assertionIndex,
                ['START-WITH ASSERTION FAILED', 'RECEIVED STRING', '   SHOULD START']);
        }
        return self;
    }

    contains(expectedValue) {
        self.assertionIndex++;
        if(!self.receivedValue.find(expectedValue)) {
            reportFailure(expectedValue, self.receivedValue,
                assertionIndex,
                ['CONTAINS ASSERTION FAILED', 'RECEIVED STRING', ' SHOULD CONTAIN']);
        }
        return self;
    }

    isEqualTo(expectedValue) {
        self.assertionIndex++;
        local expected = dataTypeXlat(expectedValue) == TypeFuncPtr
            ? expectedValue() : expectedValue;
        if(self.receivedValue != expected) {
            reportFailure(expected, self.receivedValue, assertionIndex);
        }
        return self;
    }

    /* Alias för isEqualTo */
    is(expectedValue) { return isEqualTo(expectedValue); }

    isNotEqualTo(expectedValue) {
        self.assertionIndex++;
        local expected = dataTypeXlat(expectedValue) == TypeFuncPtr
            ? expectedValue() : expectedValue;
        if(self.receivedValue == expected) {
            reportFailure(expected, self.receivedValue,
                assertionIndex,
                ['NOT-EQUAL ASSERTION FAILED', 'RECEIVED', 'SHOULD NOT EQUAL']);
        }
        return self;
    }

    hasLength(expected) {
        self.assertionIndex++;
        if(self.receivedValue.length() != expected) {
            reportFailure(expected, self.receivedValue.length(), assertionIndex);
        }
        return self;
    }

    isTrue() {
        self.assertionIndex++;
        if(self.receivedValue != true) {
            reportFailure(true, self.receivedValue,
                assertionIndex,
                ['TRUE ASSERTION FAILED', 'RECEIVED', 'NOT TRUE']);
        }
        return self;
    }

    isNil() {
        self.assertionIndex++;
        if(self.receivedValue != nil) {
            reportFailure(nil, self.receivedValue,
                assertionIndex,
                ['NIL ASSERTION FAILED', 'RECEIVED', 'EXPECTED NIL']);
        }
        return self;
    }

    isNotNil() {
        self.assertionIndex++;
        if(self.receivedValue == nil) {
            reportFailure('(not nil)', self.receivedValue,
                assertionIndex,
                ['NON-NIL ASSERTION FAILED', 'RECEIVED', 'EXPECTED NON-NIL']);
        }
        return self;
    }

    /**
     * assertThat(obj).extractingProps([&name, &plural]).isEqualTo(['dörr', nil])
     */
    extractingProps(properties) {
        if(dataType(properties) != TypeList)
            properties = [properties];
        self.receivedValue = properties.mapAll({prop: self.receivedValue.(prop)});
        return self;
    }

    /**
     * assertThat([a, b]).extracting({x: x.name}).isEqualTo(['A', 'B'])
     */
    extract(lambda) {
        self.receivedValue = self.receivedValue.mapAll({x: lambda(x)});
        return self;
    }

    /**
     * assertThat([a, b]).extracting({x: x.name}, {x: x.age}).isEqualTo([...])
     */
    extracting([lambdas]) {
        local result = new Vector();
        for(local val in self.receivedValue)
            result.append(lambdas.mapAll({fn: fn(val)}));
        self.receivedValue = result;
        return self;
    }
;

function reportFailure(expected, received, assertionIdx,
        assertionMsgs=['ASSERTION FAILED', 'RECEIVED', 'EXPECTED']) {
    divider('-');
    local idxTag = assertionIdx != nil ? ' [assertion #<<assertionIdx>>]' : '';
    local bothStrings = dataTypeXlat(received) == TypeSString
        && dataTypeXlat(expected) == TypeSString;
    local lenInfo = bothStrings
        ? ' (lengths: <<expected.length>>/<<received.length>>)' : '';
    local msg = '\n<font color=red><<assertionMsgs[1]>><<idxTag>></font>'
        + '\n<<assertionMsgs[2]>>: <font color=red>[<<received>>]</font>'
        + '\n<<assertionMsgs[3]>>: <font color=green>[<<expected>>]<<lenInfo>></font>\b';
    tadsSay(msg);
    throw new RuntimeError(msg);
}

function divider(ch?) {
    ch = (ch == nil) ? '=' : ch;
    tadsSay('\n<<makeString(ch, 64)>>\n');
}


testRunner: InitObject
    currentTest = nil
    succeeded = 0
    failed = 0
    skipped = 0
    pauseWhenDone = nil
    quitWhenDone = true
    verboseAboutSuccessfulTests = true

    execute() {
        try {
            beforeAll();
            local beforeEachCollection = [];
            local testCollection = [];
            local allTests = [];
            local afterEachCollection = [];

            forEachInstance(BeforeEach, {pt: beforeEachCollection += pt});
            forEachInstance(TestUnit, {t: allTests += t});
            forEachInstance(AfterEach, {pt: afterEachCollection += pt});

            local skippedTests = allTests.subset({t: t.skip});
            skipped = skippedTests.length();
            testCollection = allTests.subset({t: !t.skip});

            local onlyTests = testCollection.subset({t: t.only == true});
            if(onlyTests.length() > 0) {
                tadsSay('\nKör endast markerade tester (only = true):\n');
                runCollection(beforeEachCollection, onlyTests, afterEachCollection);
            } else {
                if(skipped > 0)
                    tadsSay('\nHoppar över <<skipped>> test(er) (skip = true).\n');
                tadsSay('\nTotal tests to run: <<testCollection.length()>>\n');
                divider();
                runCollection(beforeEachCollection, testCollection, afterEachCollection);
            }
            afterAll();
        } finally {
            tadsSay('\bAll tests have run:\n');
            divider('*');
            tadsSay('* succeeded:  <<succeeded>>\n');
            tadsSay('* failed:     <<failed>>\n');
            if(skipped > 0)
                tadsSay('* skipped:    <<skipped>>\n');
            divider('*');
            if(pauseWhenDone) {
                tadsSay('\b[Hit any key to exit]\b');
                yesOrNo();
            }
            if(quitWhenDone)
                throw new Exception('Tests completed');
        }
    }

    beforeAll() {}
    afterAll() {}

    counter = static 0
    runTest(test) {
        currentTest = test;
        local testName = test.name == nil ? toString(test) : test.name;
        try {
            currentTest.run();
            succeeded++;
            if(verboseAboutSuccessfulTests)
                tadsSay('\n  <font color=green>[OK] Test <<++counter>>: <<testName>></font>\n');
        } catch(Exception e) {
            failed++;
            tadsSay('  <font color=red><<testName>>  -- ** TEST FAILED **</font>\n');
            tadsSay('  [<<e.exceptionMessage>>]\n');
        }
    }

    runCollection(beforeEachCollection, testCollection, afterEachCollection) {
        testCollection.forEach(function(test) {
            beforeEachCollection.subset({z: z.group == test.group})
                .forEach({pt: pt.run()});
            runTest(test);
            afterEachCollection.subset({z: z.group == test.group})
                .forEach({pt: pt.run()});
        });
    }
;
