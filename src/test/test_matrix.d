module test.test_matrix;

import std.stdio                : writefln;
import std.math					: isClose;
import std.datetime.stopwatch	: StopWatch;

import maths;

void testMatrix() {
    testMatrix4x4Float();
    testTranspose();
    testDeterminant();
    testMultiplyByMatrix();
    testInverse();
}

private:


void testMatrix4x4Float() {
	auto m = new Matrix!float(4, 4);
	writefln("%s", m);

	assert(m.numRows()==4);
	assert(m.numColumns()==4);
	assert(m.totalCells()==16);

	StopWatch watch;
	watch.start();
	m.setValue(1);
	watch.stop();
	writefln("%s", m);
	writefln("took %s nanos", watch.peek().total!"nsecs");

	assert(m[0,0]==1);

	m.setIdentity();
	writefln("%s", m);

	auto m2 = new Matrix!float(4, 4, 1);
	auto m3 = m + 1;
	auto m4 = m2 + m3;
	writefln("%s", m3);
	writefln("%s", m4);
}

void testTranspose() {
	writefln("testing transpose");
	{
		auto m = new Matrix!float(4, 4, [0, 1, 2, 3,
		                                 4, 5, 6, 7,
		                                 8, 9,10,11,
		                                 12,13,14,15
		                                 ]);
		writefln("%s", m.getTransposed());
		assert(m.getTransposed() == [0, 4, 8,12,
		                             1, 5, 9,13,
		                             2, 6,10,14,
		                             3, 7,11,15
		                             ]);
	}
	{
		auto m = new Matrix!float(2, 3, [1, 2, 3,
		                                 4, 5, 6]);
		writefln("%s", m.getTransposed());
		assert(m.getTransposed() == [1, 4,
		                             2, 5,
		                             3, 6]);
	}
}

void testDeterminant() {
	writefln("testing determinant");
	{
		auto m = new Matrix!float(2, 2);
		m.set([3, 2,
		       5, 2]);
		writefln("%s determinant=%s", m, m.getDeterminant());
		assert(isClose!(float, float)(m.getDeterminant(), -4f));
	}
	{
		auto m = new Matrix!float(3, 3);
		m.set([4,1,2,
		       3,2,1,
		       9,3,1]);
		writefln("%s determinant=%s", m, m.getDeterminant());
		assert(isClose!(float, float)(m.getDeterminant(), -16f));
	}
	{
		auto m = new Matrix!float(4, 4);
		m.set([3, 2, 0, 1,
		       4, 0, 1, 2,
		       3, 0, 2, 1,
		       9, 2, 3, 1]);
		writefln("%s determinant=%s", m, m.getDeterminant());
		assert(isClose!(float, float)(m.getDeterminant(), 24f));
	}
}

void testMultiplyByMatrix() {
	writefln("testing multiply by matrix");
	{
		auto m = new Matrix!float(2, 2, [3,2,
		                                 5,2]);
		auto m2 = new Matrix!float(2, 2, [3,2,
		                                  5,2]);
		writefln("%s", m*m2);
		assert(m*m2 == [19,10,
		                25,14]);
	}
	{
		auto m = new Matrix!float(2, 2, [3,2,
		                                 5,2]);
		m *= m;
		writefln("%s", m);
		assert(m == [19,10,
		             25,14]);
	}
}

void testInverse() {
	writefln("testing inverse");
	{
		auto m = new Matrix!float(2, 2, [3,2,
		                                 5,2]);
		writefln("%s det = %s inverse=\n%s", m, m.getDeterminant(), m.getInverse());
		writefln("%s", m*m.getInverse());
		assert(m*m.getInverse() == [1,0,
		                            0,1]);
	}
	{
		auto m = new Matrix!float(3, 3, [3,2,1,
		                                 5,2,1,
		                                 7,1,9
		                                 ]);
		writefln("%s det = %s inverse=\n%s", m, m.getDeterminant(), m.getInverse());
		writefln("%s", m*m.getInverse());
	}
	{
		auto m = new Matrix!float(4, 4, [3,2,1,5,
		                                 5,2,1,4,
		                                 7,1,9,5,
		                                 1,5,6,7
		                                 ]);
		writefln("%s det = %s inverse=\n%s", m, m.getDeterminant(), m.getInverse());
		writefln("%s", m*m.getInverse());
	}
}
