module la

import vsl.blas
import vsl.la
import vtl

pub fn ddot(a vtl.Tensor, b vtl.Tensor) f64 {
	if !a.is_vector() || !b.is_vector() {
		panic('Tensors must be one dimensional')
	} else if a.size != b.size {
		panic('Tensors must have the same shape')
	}
	return la.vector_dot(vtl.tensor_to_varray<f64>(a), vtl.tensor_to_varray<f64>(b))
}

pub fn dger(a vtl.Tensor, b vtl.Tensor) vtl.Tensor {
	if !a.is_vector() || !b.is_vector() {
		panic('Tensors must be one dimensional')
	}
	m := la.vector_vector_tr_mul(1.0, vtl.tensor_to_varray<f64>(a), vtl.tensor_to_varray<f64>(a))
	return vtl.from_2d<f64>(m.get_deep2())
}

pub fn dnrm2(t vtl.Tensor) f64 {
	if !t.is_vector() {
		panic('Tensor must be one dimensional')
	}
	return blas.dnrm2(t.size, vtl.tensor_to_varray<f64>(t), t.strides[0])
}

pub fn det(t vtl.Tensor) f64 {
	assert_square_matrix(t)
	m := t.shape[0]
	n := t.shape[1]
	mat := la.matrix_raw(m, n, vtl.tensor_to_varray<f64>(t))
	return mat.det()
}

pub fn inv(t vtl.Tensor) vtl.Tensor {
	assert_square_matrix(t)
	mut ret := t.copy(.colmajor)
	n := t.shape[0]
	ipiv := []int{len: (n * int(sizeof(int)))}
	mut mut_ret := vtl.tensor_to_varray<f64>(ret)
	blas.dgetrf(n, n, mut mut_ret, n, ipiv)
	blas.dgetri(n, mut mut_ret, n, ipiv)
	ret.assign(vtl.new_tensor_from_varray<f64>(mut_ret, {
                shape: ret.shape,
                memory: ret.memory
        }))
	return ret
}

pub fn matmul(a vtl.Tensor, b vtl.Tensor) vtl.Tensor {
	mut dest := []f64{len: a.shape[0] * b.shape[1]}
	ma := match a.is_contiguous() {
		true { a }
		else { a.copy(.rowmajor) }
	}
	mb := match b.is_contiguous() {
		true { b }
		else { b.copy(.rowmajor) }
	}
	blas.dgemm(false, false, ma.shape[0], mb.shape[1], ma.shape[1], 1.0, vtl.tensor_to_varray<f64>(ma),
		ma.shape[1], vtl.tensor_to_varray<f64>(mb), mb.shape[1], 1.0, mut dest, mb.shape[1])
	return vtl.from_varray<f64>(dest, [a.shape[0], b.shape[1]])
}

pub fn tensordot(a vtl.Tensor, b vtl.Tensor, a_axes_ []int, b_axes_ []int) vtl.Tensor {
        a_shape := a.shape
	a_rank := a.rank()
	b_shape := b.shape
	b_rank := b.rank()
        a_axes, b_axes := correct_axes(a, b, a_axes_, b_axes_) or { panic(err) }
        tmp := irange(0, a_rank)
	notin := tmp.filter(!(it in a_axes))
	mut a_newaxes := notin
	a_newaxes << a_axes
	mut n2 := 1
	for axis in a_axes {
		n2 *= a_shape[axis]
	}
	firstdim := notin.map(a_shape[it])
	val := iarray_prod(firstdim)
	newshape_a := [val, n2]
	tmpb := irange(0, b_rank)
	notinb := tmpb.filter(!(it in b_axes))
	mut b_newaxes := b_axes
	b_newaxes << notinb
	n2 = 1
	for axis in b_axes {
		n2 *= b_shape[axis]
	}
	firstdimb := notin.map(b_shape[it])
	valb := iarray_prod(firstdimb)
	newshape_b := [n2, valb]
	mut outshape := []int{}
	outshape << firstdim
	outshape << firstdimb
	at := a.transpose(a_newaxes).reshape(newshape_a)
	bt := b.transpose(b_newaxes).reshape(newshape_b)
	res := matmul(at, bt)
	return res.reshape(outshape)
}
