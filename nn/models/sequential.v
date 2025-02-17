module models

import vtl
import vtl.autograd
import vtl.nn.loss
import vtl.nn.types

fn init() {
	println(@MOD + ' module is a WIP and not yet functional')
}

pub struct Sequential[T] {
pub mut:
	info &SequentialInfo[T]
}

// sequential creates a new sequential network with a new context.
pub fn sequential[T]() &Sequential[T] {
	ctx := autograd.ctx[T]()
	empty_layers := []types.Layer[T]{}
	return &Sequential[T]{
		info: sequential_info[T](ctx, empty_layers)
	}
}

// sequential_with_layers creates a new sequential network with a new context
// and the given layers.
pub fn sequential_with_layers[T](given_layers []types.Layer[T]) &Sequential[T] {
	ctx := autograd.ctx[T]()
	return &Sequential[T]{
		info: sequential_info[T](ctx, given_layers)
	}
}

// sequential_from_ctx creates a new sequential network with the given context.
pub fn sequential_from_ctx[T](ctx &autograd.Context[T]) &Sequential[T] {
	empty_layers := []types.Layer[T]{}
	return &Sequential[T]{
		info: sequential_info[T](ctx, empty_layers)
	}
}

// sequential_from_ctx_with_layers creates a new sequential network with the given context
// and the given layers.
pub fn sequential_from_ctx_with_layers[T](ctx &autograd.Context[T], given_layers []types.Layer[T]) &Sequential[T] {
	return &Sequential[T]{
		info: sequential_info[T](ctx, given_layers)
	}
}

// input adds a new input layer to the network
// with the given shape.
pub fn (mut nn Sequential[T]) input(shape []int) {
	nn.info.input(shape)
}

// linear adds a new linear layer to the network
// with the given output size
pub fn (mut nn Sequential[T]) linear(output_size int) {
	nn.info.linear(output_size)
}

// maxpool2d adds a new maxpool2d layer to the network
// with the given kernel size and stride.
pub fn (mut nn Sequential[T]) maxpool2d(kernel []int, padding []int, stride []int) {
	nn.info.maxpool2d(kernel, padding, stride)
}

// mse_loss sets the loss function to the mean squared error loss.
pub fn (mut nn Sequential[T]) mse_loss() {
	nn.info.mse_loss()
}

// sigmoid_cross_entropy_loss sets the loss function to the sigmoid cross entropy loss.
pub fn (mut nn Sequential[T]) sigmoid_cross_entropy_loss() {
	nn.info.sigmoid_cross_entropy_loss()
}

// softmax_cross_entropy_loss sets the loss function to the softmax cross entropy loss.
pub fn (mut nn Sequential[T]) softmax_cross_entropy_loss() {
	nn.info.softmax_cross_entropy_loss()
}

// flatten adds a new flatten layer to the network.
pub fn (mut nn Sequential[T]) flatten() {
	nn.info.flatten()
}

// relu adds a new relu layer to the network.
pub fn (mut nn Sequential[T]) relu() {
	nn.info.relu()
}

// leaky_relu adds a new leaky_relu layer to the network.
pub fn (mut nn Sequential[T]) leaky_relu() {
	nn.info.leaky_relu()
}

// elu adds a new elu layer to the network.
pub fn (mut nn Sequential[T]) elu() {
	nn.info.elu()
}

// sigmod adds a new sigmod layer to the network.
pub fn (mut nn Sequential[T]) sigmod() {
	nn.info.sigmod()
}

pub fn (mut nn Sequential[T]) forward(mut train autograd.Variable[T]) !&autograd.Variable[T] {
	for layer in nn.info.layers {
		train = *layer.forward(mut train)!
	}
	return train
}

pub fn (mut nn Sequential[T]) loss(output &autograd.Variable[T], target &vtl.Tensor[T]) !&autograd.Variable[T] {
	return loss.loss_loss[T](nn.info.loss, output, target)
}
