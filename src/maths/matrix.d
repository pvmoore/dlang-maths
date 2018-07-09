module maths.matrix;
/* ====================================================================================================================
	An M x N matrix implementation.
	
	M = number of rows
	N = number of columns
==================================================================================================================== */
import maths.all;

final class Matrix(T) {
public:
	T[] m;
	const uint M;
	const uint N;
		
	this(uint rows, uint cols)				{ M = rows; N = cols; m.length = M*N; }
	this(uint m, uint n, T initialValue) 	{ this(m, n); this.setValue(initialValue); }
	this(Matrix o) 							{ this(o.numRows(), o.numColumns()); this.copy(o); }
	this(uint rows, uint cols, T[] cells) 	{ this(rows, cols); this.set(cells); }	
	
	uint numRows() 			{ return M; }
	uint numColumns() 		{ return N; }
	uint totalCells() 		{ return M*N; }
	T[] cells()			{ return cast(T[])m.dup; }
	//float* column(uint i) 	{ return &m[i][0]; }
	//float[] column(uint i) 	{ return m[i]; }
	//T[] row(uint i)		{ return m[i]; }
	
	void setIdentity() {
		setValue(0);
		uint minDim = M < N ? M : N;
		for(int i=0; i<minDim; i++) {
			m[i*N + i] = 1;
		}
	}
	
	void setValue(T value) {
		m[] = cast(T)value;
	}
	
	void set(T[] cells) {
		m[] = cast(T[])cells[];
	}
	
	void copy(Matrix o) {
		m = o.m.dup;
	}
	
	/**
	 * Returns the transposed form of this matrix.<br>
	 * The rows and columns are simply swapped.<br>
	 * eg. an MxN matrix becomes NxM.
	 */
	Matrix getTransposed() {
		auto mat = new Matrix!T(N, M);
		if(M==N) {
			for(uint r=0; r<M; r++) {
				for(uint c=0; c<N; c++) {
					mat.m[r*N + c] = m[c*N + r];
				}
			}
		} else {
			for(uint i=0; i<M*N; i++) {
				uint sx = i/M;
				uint sy = i%M;
				uint dx = i%M;
				uint dy = i/M;
				mat.m[dy*M+dx] = m[sy*N+sx];
			}
		}
		return mat;
	}
	
	/**
	 * Returns: The inverse of this matrix (A<sup>-1</sup>)<br>
	 * A * A<sup>-1</sup> = I where I is the identity matrix.
	 * If the determinant is 0 then this matrix is not invertable.
	 */
	Matrix getInverse() {
		//assert(M==N);
		if(M < 4) {
			T d = getDeterminant();
			if(d==0) {
				// no determinant. just return a copy of this
				return new Matrix!T(this);
			}
			d = 1/d;
			if(M==1) {
				return new Matrix!T(M, N, [ m[0]/d ]);
			} else if(M==2) {
				return new Matrix!T(M, N, [
				    m[3]*d, -m[1]*d,
				    -m[2]*d, m[0]*d 
				    ]);                        
			} 
			return new Matrix!T(M, N, [ (m[1*N+1]*m[2*N+2]-m[1*N+2]*m[2*N+1])*d, -(m[0*N+1]*m[2*N+2]-m[0*N+2]*m[2*N+1])*d, (m[0*N+1]*m[1*N+2]-m[0*N+2]*m[1*N+1])*d,
			                           -(m[1*N+0]*m[2*N+2]-m[1*N+2]*m[2*N+0])*d,  (m[0*N+0]*m[2*N+2]-m[0*N+2]*m[2*N+0])*d,-(m[0*N+0]*m[1*N+2]-m[0*N+2]*m[1*N+0])*d,
			                            (m[1*N+0]*m[2*N+1]-m[1*N+1]*m[2*N+0])*d, -(m[0*N+0]*m[2*N+1]-m[0*N+1]*m[2*N+0])*d, (m[0*N+0]*m[1*N+1]-m[0*N+1]*m[1*N+0])*d
			                           ]);
		}
		// ho hum
		Matrix lu;
		Matrix inv = new Matrix!T(M, N);
		T[] col;	col.length = N;
		int[] permutation;
		decomposeLU(lu, permutation);
		
		for(int j=0; j<M; j++) {
			col[]  = cast(T)0;
			col[j] = cast(T)1;

			backSubstitute(lu, col, permutation);

			for(int i=0; i<M; i++) {
				inv.m[i*N+j] = col[i];
			}
        }

		return inv;
	}
	
	/**
	 * Returns: The determinant of this matrix.<br>
	 * <b>Note:</b>The matrix must be square. 
	 */
	T getDeterminant() {
		//assert(M==N);
		if(M==1) {
			return m[0];
		} else if(M==2) {
			return (m[0]*m[3]) - (m[1]*m[2]);
		} else if(M==3) {
			return m[0*N + 0]*m[1*N + 1]*m[2*N + 2] -
		           m[0*N + 0]*m[2*N + 1]*m[1*N + 2] +
		           m[1*N + 0]*m[2*N + 1]*m[0*N + 2] -
		           m[1*N + 0]*m[0*N + 1]*m[2*N + 2] +
		           m[2*N + 0]*m[0*N + 1]*m[1*N + 2] -
		           m[2*N + 0]*m[1*N + 1]*m[0*N + 2];
		} 
		// we are going to have to do some serious maths now
		Matrix lu;
		int[] permutation;
		return decomposeLU(lu, permutation);
	}
	
	override string toString() {
		string s; 
		for(uint r=0; r<M; r++) {
			for(uint c=0; c<N; c++) {
				//s ~= formatReal(cast(T)m[r*N + c]);
				s ~= format("%s",m[r*N + c]); 
				if(c<N-1) s ~= "  ";
			}
			s ~= "\n";
		}
		
		return s;
	}
	
	bool opEquals(T[] cells) {
		return m[] == cast(T[])cells[];
	}
	
	bool opEquals(Matrix!T o) {
		return m[] == o.m[];
	}
	
	// ------------------------------------------------------------------------------------------------------------------
	// indexing
	// ------------------------------------------------------------------------------------------------------------------
	
	T opIndex(uint r, uint c) {
		return m[r*N + c];
	}
	
	T opIndexAssign(T value, uint index) {
		return m[index] = cast(T)value;
	}
	
	T opIndexAssign(T value, uint r, uint c) {
		return m[r*N + c] = cast(T)value;
	}
	
	// ------------------------------------------------------------------------------------------------------------------
	// operators
	// ------------------------------------------------------------------------------------------------------------------
	
	auto opAdd(T s) {
		auto mat = new Matrix!T(M, N);
		mat.m[] = m[] + cast(T)s;
		return mat;
	}
	
	auto opAdd(Matrix o) {
		auto mat = new Matrix!T(M, N);
		mat.m[] = o.m[] + m[]; 
		return mat;
	}
	
	void opAddAssign(T s) {
		m[] += cast(T)s;
	}
	
	void opAddAssign(Matrix o) {
		m[] += o.m[];
	}
	
	auto opSub(T s) {
		auto mat = new Matrix!T(M, N);
		mat.m[] = m[] - cast(T)s;
		return mat;
	}
	
	auto opSub(Matrix o) {
		auto mat = new Matrix!T(M, N);
		mat.m[] = o.m[] - m[]; 
		return mat;
	}
	
	void opSubAssign(T s) {
		m[] -= cast(T)s;
	}
	
	void opSubAssign(Matrix o) {
		m[] -= o.m[];
	}
	
	auto opMul(T s) {
		auto mat = new Matrix!T(M, N);
		mat.m[] = m[] * cast(T)s;
		return mat;
	}
	
	auto opMul(Matrix o) {
		//assert(N==o.M);
		auto mat = new Matrix!T(M, N, 0);
		for(int r=0; r<M; r++) {
			for(int c=0; c<N; c++) {
				for(int k=0; k<N; k++) {
					mat.m[r*N+c] += m[r*N+k] * o.m[k*o.N+c]; 
				}
			}
		}
		return mat;
	}
	
	void opMulAssign(T s) {
		m[] *= cast(T)s;
	}
	
	void opMulAssign(Matrix o) {
		//assert(N==o.M);
		auto mat = new Matrix!T(M, N, 0);
		for(int r=0; r<M; r++) {
			for(int c=0; c<N; c++) {
				for(int k=0; k<N; k++) {
					mat.m[r*N+c] += m[r*N+k] * o.m[k*o.N+c]; 
				}
			}
		}
		this.copy(mat);
	}
	
	auto opDiv(T s) {
		auto mat = new Matrix!T(M, N);
		mat.m[] = m[] / cast(T)s;
		return mat;
	}
	
	auto opDivAssign(T s) {
		T r = 1/s;
		m[] *= cast(T)r;
	}
	
	// ------------------------------------------------------------------------------------------------------------------
	// private
	// ------------------------------------------------------------------------------------------------------------------
	
	/**
	 * Perform the backsubstitution to solve Ax = b for x.
	 */
	private void backSubstitute(Matrix lu, ref T[] col, ref int[] permutation) {
		int i, ii=-1, ip, j;
	    T sum;

	    for(i=0; i<M; i++) {
	    	ip = permutation[i];
	        sum = col[ip];
	        col[ip] = col[i];
	        if(ii > -1) {
	            // aries shoudl the j<=i-1 be <?
	            for(j=ii; j<=i-1; j++) {
	            	sum -= lu.m[i*M+j] * col[j];
	            }
	        } else if(sum != 0.0) {
	        	ii = i;
	        }
	        col[i] = cast(T)sum;
	    }

	    for(i = M-1; i>=0; i--) {
	        sum = col[i];
	        for (j=i+1; j<M; j++) {
	        	sum -= lu.m[i*M+j] * col[j];
	        }
	        col[i] = sum / lu.m[i*M+i];
	    }
	}
	/**
	 * Calculates the determinant using LU decomposition.
	 * Stolen from Numerical Recipes in C
	 * @see http://en.wikipedia.org/wiki/LU_decomposition
	 */
	private T decomposeLU(out Matrix lu, out int[] permutation) {
		permutation.length = N;
		T[] vv;	vv.length = N;
		lu = new Matrix!T(M, N);
		int imax;
		T big, dum, sum, temp;

		int i, j, k;
		int count;

		for(i=0; i<N; i++) {
			big = 0;
			for(j=0; j<N; j++) {
				lu.m[i*N+j] = m[i*N+j];  // copy along the way
				if((temp = abs(cast(T)lu.m[i*N+j])) > big) big = temp;
			}
			if(big == 0) {
				// determinant must be 0
				return 0;
			}
			vv[i] = cast(T)(1.0/big);
		}
	  
		for(j=0; j<N; j++) {
			for(i=0; i<j; i++) {
				sum = lu.m[i*N+j];
				for(k=0; k<i; k++) sum -= lu.m[i*N+k] * lu.m[k*N+j];
				lu.m[i*N+j] = cast(T)sum;
			}
			big = cast(T)0.0;
			
			for(i=j; i<N; i++) {
				sum = lu.m[i*N+j];
				for(k=0; k<j; k++) {
					sum -= lu.m[i*N+k] * lu.m[k*N+j];
				}
				lu.m[i*N+j] = cast(T)sum;
				if((dum = vv[i] * abs(sum)) >= big) {
					big = dum;
					imax = i;
				}
			}
			
			if(j != imax) {
				for(k=0; k<N; k++) {
					dum = lu.m[imax*N+k];
					lu.m[imax*N+k] = lu.m[j*N+k];
					lu.m[j*N+k] = cast(T)dum;
				}
				count++;
				vv[imax] = vv[j];
			}
			
			permutation[j] = imax;
			if(lu.m[j*N+j] == 0.0)
				m[j*N+j] = cast(T)T.min_normal; //cast(T)1.0e-11;

			if(j != N-1) {
				dum = 1.0/(lu.m[j*N+j]);
				for(i=j+1; i<N; i++)
					lu.m[i*N+j] *= dum;
			}
		}
		
		T result = (count&1) ? -1 : 1; 
	    for(j = 0; j < N; j++) {
	    	result *= cast(T)lu.m[j*N + j];
	    }
	    return result;
	}
	
	// slow version of getting the determinant
	T determinantSlow(T[] mat, int n) {
		T result = 0;
		if(n == 1) {
			return mat[0];
		}
		if(n == 2) {
			return mat[0] * mat[3] - mat[1] * mat[2];
		}
		for(int i = 0; i < n; i++) {
			int nn = n-1;
			T[] temp; temp.length = nn*nn; 
	
			for(int j = 1; j < n; j++) {
				for(int k = 0; k < n; k++) {
		
				if(k < i) {
					temp[(j - 1)*nn + k] = mat[j*n + k];
				} else if(k > i) {
					temp[(j - 1)*nn + (k - 1)] = mat[j*n + k];
				}
		
				}
			}
			result += mat[0*n+i] * pow(-1.0, i) * determinantSlow(temp, nn);
		}
		return result;
	} 
}

