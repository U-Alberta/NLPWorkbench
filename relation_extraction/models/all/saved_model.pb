´Ï
Ê--
:
Add
x"T
y"T
z"T"
Ttype:
2	
h
All	
input

reduction_indices"Tidx

output
"
	keep_dimsbool( "
Tidxtype0:
2	
P
Assert
	condition
	
data2T"
T
list(type)(0"
	summarizeint
x
Assign
ref"T

value"T

output_ref"T"	
Ttype"
validate_shapebool("
use_lockingbool(
B
AssignVariableOp
resource
value"dtype"
dtypetype
~
BiasAdd

value"T	
bias"T
output"T" 
Ttype:
2	"-
data_formatstringNHWC:
NHWCNCHW
h
ConcatV2
values"T*N
axis"Tidx
output"T"
Nint(0"	
Ttype"
Tidxtype0:
2	
8
Const
output"dtype"
valuetensor"
dtypetype
y
Enter	
data"T
output"T"	
Ttype"

frame_namestring"
is_constantbool( "
parallel_iterationsint

B
Equal
x"T
y"T
z
"
Ttype:
2	

)
Exit	
data"T
output"T"	
Ttype
W

ExpandDims

input"T
dim"Tdim
output"T"	
Ttype"
Tdimtype0:
2	
^
Fill
dims"
index_type

value"T
output"T"	
Ttype"

index_typetype0:
2	

GatherV2
params"Tparams
indices"Tindices
axis"Taxis
output"Tparams"
Tparamstype"
Tindicestype:
2	"
Taxistype:
2	
B
GreaterEqual
x"T
y"T
z
"
Ttype:
2	
.
Identity

input"T
output"T"	
Ttype
:
Less
x"T
y"T
z
"
Ttype:
2	
$

LogicalAnd
x

y

z

!
LoopCond	
input


output

q
MatMul
a"T
b"T
product"T"
transpose_abool( "
transpose_bbool( "
Ttype:

2	

Max

input"T
reduction_indices"Tidx
output"T"
	keep_dimsbool( " 
Ttype:
2	"
Tidxtype0:
2	
;
Maximum
x"T
y"T
z"T"
Ttype:

2	

Mean

input"T
reduction_indices"Tidx
output"T"
	keep_dimsbool( " 
Ttype:
2	"
Tidxtype0:
2	
N
Merge
inputs"T*N
output"T
value_index"	
Ttype"
Nint(0
e
MergeV2Checkpoints
checkpoint_prefixes
destination_prefix"
delete_old_dirsbool(

Min

input"T
reduction_indices"Tidx
output"T"
	keep_dimsbool( " 
Ttype:
2	"
Tidxtype0:
2	
;
Minimum
x"T
y"T
z"T"
Ttype:

2	
=
Mul
x"T
y"T
z"T"
Ttype:
2	
2
NextIteration	
data"T
output"T"	
Ttype

NoOp
M
Pack
values"T*N
output"T"
Nint(0"	
Ttype"
axisint 
C
Placeholder
output"dtype"
dtypetype"
shapeshape:
X
PlaceholderWithDefault
input"dtype
output"dtype"
dtypetype"
shapeshape

Prod

input"T
reduction_indices"Tidx
output"T"
	keep_dimsbool( " 
Ttype:
2	"
Tidxtype0:
2	
~
RandomUniform

shape"T
output"dtype"
seedint "
seed2int "
dtypetype:
2"
Ttype:
2	
a
Range
start"Tidx
limit"Tidx
delta"Tidx
output"Tidx"
Tidxtype0:	
2	
@
ReadVariableOp
resource
value"dtype"
dtypetype
E
Relu
features"T
activations"T"
Ttype:
2	
[
Reshape
tensor"T
shape"Tshape
output"T"	
Ttype"
Tshapetype0:
2	
o
	RestoreV2

prefix
tensor_names
shape_and_slices
tensors2dtypes"
dtypes
list(type)(0

ReverseSequence

input"T
seq_lengths"Tlen
output"T"
seq_dimint"
	batch_dimint "	
Ttype"
Tlentype0	:
2	
0
Round
x"T
y"T"
Ttype:

2	
l
SaveV2

prefix
tensor_names
shape_and_slices
tensors2dtypes"
dtypes
list(type)(0
?
Select
	condition

t"T
e"T
output"T"	
Ttype
P
Shape

input"T
output"out_type"	
Ttype"
out_typetype0:
2	
H
ShardedFilename
basename	
shard

num_shards
filename
0
Sigmoid
x"T
y"T"
Ttype:

2
9
Softmax
logits"T
softmax"T"
Ttype:
2
[
Split
	split_dim

value"T
output"T*	num_split"
	num_splitint(0"	
Ttype
ö
StridedSlice

input"T
begin"Index
end"Index
strides"Index
output"T"	
Ttype"
Indextype:
2	"

begin_maskint "
end_maskint "
ellipsis_maskint "
new_axis_maskint "
shrink_axis_maskint 
N

StringJoin
inputs*N

output"
Nint(0"
	separatorstring 
:
Sub
x"T
y"T
z"T"
Ttype:
2	
M
Switch	
data"T
pred

output_false"T
output_true"T"	
Ttype
-
Tanh
x"T
y"T"
Ttype:

2
{
TensorArrayGatherV3

handle
indices
flow_in
value"dtype"
dtypetype"
element_shapeshape:
Y
TensorArrayReadV3

handle	
index
flow_in
value"dtype"
dtypetype
d
TensorArrayScatterV3

handle
indices

value"T
flow_in
flow_out"	
Ttype
9
TensorArraySizeV3

handle
flow_in
size
Þ
TensorArrayV3
size

handle
flow"
dtypetype"
element_shapeshape:"
dynamic_sizebool( "
clear_after_readbool("$
identical_element_shapesbool( "
tensor_array_namestring 
`
TensorArrayWriteV3

handle	
index

value"T
flow_in
flow_out"	
Ttype
P
	Transpose
x"T
perm"Tperm
y"T"	
Ttype"
Tpermtype0:
2	
q
VarHandleOp
resource"
	containerstring "
shared_namestring "
dtypetype"
shapeshape
9
VarIsInitializedOp
resource
is_initialized

s

VariableV2
ref"dtype"
shapeshape"
dtypetype"
	containerstring "
shared_namestring "serve*1.13.12b'v1.13.1-0-g6612da8951'8


global_step/Initializer/zerosConst*
value	B	 R *
_class
loc:@global_step*
dtype0	*
_output_shapes
: 
k
global_step
VariableV2*
_class
loc:@global_step*
dtype0	*
_output_shapes
: *
shape: 

global_step/AssignAssignglobal_stepglobal_step/Initializer/zeros*
T0	*
_class
loc:@global_step*
_output_shapes
: 
j
global_step/readIdentityglobal_step*
T0	*
_class
loc:@global_step*
_output_shapes
: 
]
ConstConst*
dtype0*
_output_shapes
: *(
valueB Bdata/all/train.tfrecord
g
flat_filenames/shapeConst*
valueB:
ÿÿÿÿÿÿÿÿÿ*
dtype0*
_output_shapes
:
[
flat_filenamesReshapeConstflat_filenames/shape*
_output_shapes
:*
T0
c
numWordsPlaceholder*
dtype0*#
_output_shapes
:ÿÿÿÿÿÿÿÿÿ*
shape:ÿÿÿÿÿÿÿÿÿ

wordFeaturesPlaceholder*
dtype0*5
_output_shapes#
!:ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÐ**
shape!:ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÐ

lmLayersPlaceholder*
dtype0*9
_output_shapes'
%:#ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ*.
shape%:#ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
s
globalFeaturesPlaceholder*
dtype0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
shape:ÿÿÿÿÿÿÿÿÿú
r
'seqclassifier/encoder/concat/concat_dimConst*
valueB :
ÿÿÿÿÿÿÿÿÿ*
dtype0*
_output_shapes
: 
v
seqclassifier/encoder/concatIdentitywordFeatures*
T0*5
_output_shapes#
!:ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÐ
t
)seqclassifier/encoder/concat_1/concat_dimConst*
valueB :
þÿÿÿÿÿÿÿÿ*
dtype0*
_output_shapes
: 
x
seqclassifier/encoder/concat_1IdentitylmLayers*
T0*9
_output_shapes'
%:#ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
t
*seqclassifier/encoder/random_uniform/shapeConst*
valueB:*
dtype0*
_output_shapes
:
m
(seqclassifier/encoder/random_uniform/minConst*
dtype0*
_output_shapes
: *
valueB
 *    
m
(seqclassifier/encoder/random_uniform/maxConst*
dtype0*
_output_shapes
: *
valueB
 *  ?
¡
2seqclassifier/encoder/random_uniform/RandomUniformRandomUniform*seqclassifier/encoder/random_uniform/shape*
dtype0*
_output_shapes
:*
T0
¤
(seqclassifier/encoder/random_uniform/subSub(seqclassifier/encoder/random_uniform/max(seqclassifier/encoder/random_uniform/min*
_output_shapes
: *
T0
²
(seqclassifier/encoder/random_uniform/mulMul2seqclassifier/encoder/random_uniform/RandomUniform(seqclassifier/encoder/random_uniform/sub*
_output_shapes
:*
T0
¤
$seqclassifier/encoder/random_uniformAdd(seqclassifier/encoder/random_uniform/mul(seqclassifier/encoder/random_uniform/min*
T0*
_output_shapes
:
f
seqclassifier/encoder/Variable
VariableV2*
dtype0*
_output_shapes
:*
shape:
Í
%seqclassifier/encoder/Variable/AssignAssignseqclassifier/encoder/Variable$seqclassifier/encoder/random_uniform*
_output_shapes
:*
T0*1
_class'
%#loc:@seqclassifier/encoder/Variable
§
#seqclassifier/encoder/Variable/readIdentityseqclassifier/encoder/Variable*
_output_shapes
:*
T0*1
_class'
%#loc:@seqclassifier/encoder/Variable
r
seqclassifier/encoder/SoftmaxSoftmax#seqclassifier/encoder/Variable/read*
T0*
_output_shapes
:
n
$seqclassifier/encoder/Tensordot/axesConst*
dtype0*
_output_shapes
:*
valueB:
y
$seqclassifier/encoder/Tensordot/freeConst*
dtype0*
_output_shapes
:*!
valueB"          
s
%seqclassifier/encoder/Tensordot/ShapeShapeseqclassifier/encoder/concat_1*
T0*
_output_shapes
:
o
-seqclassifier/encoder/Tensordot/GatherV2/axisConst*
value	B : *
dtype0*
_output_shapes
: 
ø
(seqclassifier/encoder/Tensordot/GatherV2GatherV2%seqclassifier/encoder/Tensordot/Shape$seqclassifier/encoder/Tensordot/free-seqclassifier/encoder/Tensordot/GatherV2/axis*
_output_shapes
:*
Taxis0*
Tindices0*
Tparams0
q
/seqclassifier/encoder/Tensordot/GatherV2_1/axisConst*
dtype0*
_output_shapes
: *
value	B : 
ü
*seqclassifier/encoder/Tensordot/GatherV2_1GatherV2%seqclassifier/encoder/Tensordot/Shape$seqclassifier/encoder/Tensordot/axes/seqclassifier/encoder/Tensordot/GatherV2_1/axis*
_output_shapes
:*
Taxis0*
Tindices0*
Tparams0
o
%seqclassifier/encoder/Tensordot/ConstConst*
dtype0*
_output_shapes
:*
valueB: 

$seqclassifier/encoder/Tensordot/ProdProd(seqclassifier/encoder/Tensordot/GatherV2%seqclassifier/encoder/Tensordot/Const*
_output_shapes
: *
T0
q
'seqclassifier/encoder/Tensordot/Const_1Const*
valueB: *
dtype0*
_output_shapes
:
¤
&seqclassifier/encoder/Tensordot/Prod_1Prod*seqclassifier/encoder/Tensordot/GatherV2_1'seqclassifier/encoder/Tensordot/Const_1*
_output_shapes
: *
T0
m
+seqclassifier/encoder/Tensordot/concat/axisConst*
dtype0*
_output_shapes
: *
value	B : 
Ù
&seqclassifier/encoder/Tensordot/concatConcatV2$seqclassifier/encoder/Tensordot/free$seqclassifier/encoder/Tensordot/axes+seqclassifier/encoder/Tensordot/concat/axis*
N*
_output_shapes
:*
T0
©
%seqclassifier/encoder/Tensordot/stackPack$seqclassifier/encoder/Tensordot/Prod&seqclassifier/encoder/Tensordot/Prod_1*
N*
_output_shapes
:*
T0
Â
)seqclassifier/encoder/Tensordot/transpose	Transposeseqclassifier/encoder/concat_1&seqclassifier/encoder/Tensordot/concat*9
_output_shapes'
%:#ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ*
T0
¿
'seqclassifier/encoder/Tensordot/ReshapeReshape)seqclassifier/encoder/Tensordot/transpose%seqclassifier/encoder/Tensordot/stack*0
_output_shapes
:ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ*
T0
z
0seqclassifier/encoder/Tensordot/transpose_1/permConst*
valueB: *
dtype0*
_output_shapes
:
®
+seqclassifier/encoder/Tensordot/transpose_1	Transposeseqclassifier/encoder/Softmax0seqclassifier/encoder/Tensordot/transpose_1/perm*
_output_shapes
:*
T0

/seqclassifier/encoder/Tensordot/Reshape_1/shapeConst*
valueB"      *
dtype0*
_output_shapes
:
»
)seqclassifier/encoder/Tensordot/Reshape_1Reshape+seqclassifier/encoder/Tensordot/transpose_1/seqclassifier/encoder/Tensordot/Reshape_1/shape*
_output_shapes

:*
T0
¶
&seqclassifier/encoder/Tensordot/MatMulMatMul'seqclassifier/encoder/Tensordot/Reshape)seqclassifier/encoder/Tensordot/Reshape_1*'
_output_shapes
:ÿÿÿÿÿÿÿÿÿ*
T0
j
'seqclassifier/encoder/Tensordot/Const_2Const*
valueB *
dtype0*
_output_shapes
: 
o
-seqclassifier/encoder/Tensordot/concat_1/axisConst*
dtype0*
_output_shapes
: *
value	B : 
ä
(seqclassifier/encoder/Tensordot/concat_1ConcatV2(seqclassifier/encoder/Tensordot/GatherV2'seqclassifier/encoder/Tensordot/Const_2-seqclassifier/encoder/Tensordot/concat_1/axis*
N*
_output_shapes
:*
T0
¼
seqclassifier/encoder/TensordotReshape&seqclassifier/encoder/Tensordot/MatMul(seqclassifier/encoder/Tensordot/concat_1*
T0*5
_output_shapes#
!:ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
n
#seqclassifier/encoder/concat_2/axisConst*
dtype0*
_output_shapes
: *
valueB :
ÿÿÿÿÿÿÿÿÿ
×
seqclassifier/encoder/concat_2ConcatV2seqclassifier/encoder/concatseqclassifier/encoder/Tensordot#seqclassifier/encoder/concat_2/axis*
T0*
N*5
_output_shapes#
!:ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÐ
t
2seqclassifier/encoder/bidirectional_rnn/fw/fw/RankConst*
dtype0*
_output_shapes
: *
value	B :
{
9seqclassifier/encoder/bidirectional_rnn/fw/fw/range/startConst*
dtype0*
_output_shapes
: *
value	B :
{
9seqclassifier/encoder/bidirectional_rnn/fw/fw/range/deltaConst*
dtype0*
_output_shapes
: *
value	B :

3seqclassifier/encoder/bidirectional_rnn/fw/fw/rangeRange9seqclassifier/encoder/bidirectional_rnn/fw/fw/range/start2seqclassifier/encoder/bidirectional_rnn/fw/fw/Rank9seqclassifier/encoder/bidirectional_rnn/fw/fw/range/delta*
_output_shapes
:

=seqclassifier/encoder/bidirectional_rnn/fw/fw/concat/values_0Const*
dtype0*
_output_shapes
:*
valueB"       
{
9seqclassifier/encoder/bidirectional_rnn/fw/fw/concat/axisConst*
dtype0*
_output_shapes
: *
value	B : 

4seqclassifier/encoder/bidirectional_rnn/fw/fw/concatConcatV2=seqclassifier/encoder/bidirectional_rnn/fw/fw/concat/values_03seqclassifier/encoder/bidirectional_rnn/fw/fw/range9seqclassifier/encoder/bidirectional_rnn/fw/fw/concat/axis*
T0*
N*
_output_shapes
:
Ú
7seqclassifier/encoder/bidirectional_rnn/fw/fw/transpose	Transposeseqclassifier/encoder/concat_24seqclassifier/encoder/bidirectional_rnn/fw/fw/concat*5
_output_shapes#
!:ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÐ*
T0

=seqclassifier/encoder/bidirectional_rnn/fw/fw/sequence_lengthIdentitynumWords*#
_output_shapes
:ÿÿÿÿÿÿÿÿÿ*
T0

3seqclassifier/encoder/bidirectional_rnn/fw/fw/ShapeShape7seqclassifier/encoder/bidirectional_rnn/fw/fw/transpose*
T0*
_output_shapes
:

Aseqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice/stackConst*
valueB:*
dtype0*
_output_shapes
:

Cseqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice/stack_1Const*
dtype0*
_output_shapes
:*
valueB:

Cseqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice/stack_2Const*
dtype0*
_output_shapes
:*
valueB:

;seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_sliceStridedSlice3seqclassifier/encoder/bidirectional_rnn/fw/fw/ShapeAseqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice/stackCseqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice/stack_1Cseqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice/stack_2*
_output_shapes
: *
shrink_axis_mask*
T0*
Index0
¦
dseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims/dimConst*
dtype0*
_output_shapes
: *
value	B : 
¶
`seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims
ExpandDims;seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slicedseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims/dim*
_output_shapes
:*
T0
¦
[seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/ConstConst*
dtype0*
_output_shapes
:*
valueB:ú
£
aseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/concat/axisConst*
value	B : *
dtype0*
_output_shapes
: 
¸
\seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/concatConcatV2`seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims[seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/Constaseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/concat/axis*
T0*
N*
_output_shapes
:
¦
aseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/zeros/ConstConst*
dtype0*
_output_shapes
: *
valueB
 *    
×
[seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/zerosFill\seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/concataseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/zeros/Const*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
¨
fseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_1/dimConst*
value	B : *
dtype0*
_output_shapes
: 
º
bseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_1
ExpandDims;seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slicefseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_1/dim*
_output_shapes
:*
T0
¨
]seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/Const_1Const*
dtype0*
_output_shapes
:*
valueB:ú
¨
fseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_2/dimConst*
dtype0*
_output_shapes
: *
value	B : 
º
bseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_2
ExpandDims;seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slicefseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_2/dim*
_output_shapes
:*
T0
¨
]seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/Const_2Const*
valueB:ú*
dtype0*
_output_shapes
:
¥
cseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/concat_1/axisConst*
value	B : *
dtype0*
_output_shapes
: 
À
^seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/concat_1ConcatV2bseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_2]seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/Const_2cseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/concat_1/axis*
T0*
N*
_output_shapes
:
¨
cseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/zeros_1/ConstConst*
valueB
 *    *
dtype0*
_output_shapes
: 
Ý
]seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/zeros_1Fill^seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/concat_1cseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/zeros_1/Const*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
¨
fseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_3/dimConst*
dtype0*
_output_shapes
: *
value	B : 
º
bseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_3
ExpandDims;seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slicefseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_3/dim*
T0*
_output_shapes
:
¨
]seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/Const_3Const*
dtype0*
_output_shapes
:*
valueB:ú
¿
}seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims/dimConst*
value	B : *
dtype0*
_output_shapes
: 
è
yseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims
ExpandDims;seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice}seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims/dim*
T0*
_output_shapes
:
¿
tseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ConstConst*
valueB:ú*
dtype0*
_output_shapes
:
¼
zseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/concat/axisConst*
dtype0*
_output_shapes
: *
value	B : 

useqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/concatConcatV2yseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDimstseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/Constzseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/concat/axis*
N*
_output_shapes
:*
T0
¿
zseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/zeros/ConstConst*
dtype0*
_output_shapes
: *
valueB
 *    
¢
tseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/zerosFilluseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/concatzseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/zeros/Const*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
Á
seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_1/dimConst*
dtype0*
_output_shapes
: *
value	B : 
ì
{seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_1
ExpandDims;seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_sliceseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_1/dim*
_output_shapes
:*
T0
Á
vseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/Const_1Const*
dtype0*
_output_shapes
:*
valueB:ú
Á
seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_2/dimConst*
value	B : *
dtype0*
_output_shapes
: 
ì
{seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_2
ExpandDims;seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_sliceseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_2/dim*
_output_shapes
:*
T0
Á
vseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/Const_2Const*
valueB:ú*
dtype0*
_output_shapes
:
¾
|seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/concat_1/axisConst*
dtype0*
_output_shapes
: *
value	B : 
¤
wseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/concat_1ConcatV2{seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_2vseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/Const_2|seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/concat_1/axis*
T0*
N*
_output_shapes
:
Á
|seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/zeros_1/ConstConst*
valueB
 *    *
dtype0*
_output_shapes
: 
¨
vseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/zeros_1Fillwseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/concat_1|seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/zeros_1/Const*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
Á
seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_3/dimConst*
dtype0*
_output_shapes
: *
value	B : 
ì
{seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_3
ExpandDims;seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_sliceseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_3/dim*
T0*
_output_shapes
:
Á
vseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/Const_3Const*
dtype0*
_output_shapes
:*
valueB:ú
¢
5seqclassifier/encoder/bidirectional_rnn/fw/fw/Shape_1Shape=seqclassifier/encoder/bidirectional_rnn/fw/fw/sequence_length*
_output_shapes
:*
T0
¦
3seqclassifier/encoder/bidirectional_rnn/fw/fw/stackPack;seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice*
N*
_output_shapes
:*
T0
Í
3seqclassifier/encoder/bidirectional_rnn/fw/fw/EqualEqual5seqclassifier/encoder/bidirectional_rnn/fw/fw/Shape_13seqclassifier/encoder/bidirectional_rnn/fw/fw/stack*
_output_shapes
:*
T0
}
3seqclassifier/encoder/bidirectional_rnn/fw/fw/ConstConst*
valueB: *
dtype0*
_output_shapes
:
º
1seqclassifier/encoder/bidirectional_rnn/fw/fw/AllAll3seqclassifier/encoder/bidirectional_rnn/fw/fw/Equal3seqclassifier/encoder/bidirectional_rnn/fw/fw/Const*
_output_shapes
: 
Ø
:seqclassifier/encoder/bidirectional_rnn/fw/fw/Assert/ConstConst*n
valueeBc B]Expected shape for Tensor seqclassifier/encoder/bidirectional_rnn/fw/fw/sequence_length:0 is *
dtype0*
_output_shapes
: 

<seqclassifier/encoder/bidirectional_rnn/fw/fw/Assert/Const_1Const*
dtype0*
_output_shapes
: *!
valueB B but saw shape: 
à
Bseqclassifier/encoder/bidirectional_rnn/fw/fw/Assert/Assert/data_0Const*n
valueeBc B]Expected shape for Tensor seqclassifier/encoder/bidirectional_rnn/fw/fw/sequence_length:0 is *
dtype0*
_output_shapes
: 

Bseqclassifier/encoder/bidirectional_rnn/fw/fw/Assert/Assert/data_2Const*!
valueB B but saw shape: *
dtype0*
_output_shapes
: 
û
;seqclassifier/encoder/bidirectional_rnn/fw/fw/Assert/AssertAssert1seqclassifier/encoder/bidirectional_rnn/fw/fw/AllBseqclassifier/encoder/bidirectional_rnn/fw/fw/Assert/Assert/data_03seqclassifier/encoder/bidirectional_rnn/fw/fw/stackBseqclassifier/encoder/bidirectional_rnn/fw/fw/Assert/Assert/data_25seqclassifier/encoder/bidirectional_rnn/fw/fw/Shape_1*
T
2
ð
9seqclassifier/encoder/bidirectional_rnn/fw/fw/CheckSeqLenIdentity=seqclassifier/encoder/bidirectional_rnn/fw/fw/sequence_length<^seqclassifier/encoder/bidirectional_rnn/fw/fw/Assert/Assert*
T0*#
_output_shapes
:ÿÿÿÿÿÿÿÿÿ

5seqclassifier/encoder/bidirectional_rnn/fw/fw/Shape_2Shape7seqclassifier/encoder/bidirectional_rnn/fw/fw/transpose*
T0*
_output_shapes
:

Cseqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_1/stackConst*
dtype0*
_output_shapes
:*
valueB: 

Eseqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_1/stack_1Const*
dtype0*
_output_shapes
:*
valueB:

Eseqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_1/stack_2Const*
dtype0*
_output_shapes
:*
valueB:

=seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_1StridedSlice5seqclassifier/encoder/bidirectional_rnn/fw/fw/Shape_2Cseqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_1/stackEseqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_1/stack_1Eseqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_1/stack_2*
shrink_axis_mask*
T0*
Index0*
_output_shapes
: 

5seqclassifier/encoder/bidirectional_rnn/fw/fw/Shape_3Shape7seqclassifier/encoder/bidirectional_rnn/fw/fw/transpose*
T0*
_output_shapes
:

Cseqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_2/stackConst*
valueB:*
dtype0*
_output_shapes
:

Eseqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_2/stack_1Const*
valueB:*
dtype0*
_output_shapes
:

Eseqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_2/stack_2Const*
dtype0*
_output_shapes
:*
valueB:

=seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_2StridedSlice5seqclassifier/encoder/bidirectional_rnn/fw/fw/Shape_3Cseqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_2/stackEseqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_2/stack_1Eseqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_2/stack_2*
shrink_axis_mask*
T0*
Index0*
_output_shapes
: 
~
<seqclassifier/encoder/bidirectional_rnn/fw/fw/ExpandDims/dimConst*
value	B : *
dtype0*
_output_shapes
: 
è
8seqclassifier/encoder/bidirectional_rnn/fw/fw/ExpandDims
ExpandDims=seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_2<seqclassifier/encoder/bidirectional_rnn/fw/fw/ExpandDims/dim*
_output_shapes
:*
T0

5seqclassifier/encoder/bidirectional_rnn/fw/fw/Const_1Const*
valueB:ú*
dtype0*
_output_shapes
:
}
;seqclassifier/encoder/bidirectional_rnn/fw/fw/concat_1/axisConst*
dtype0*
_output_shapes
: *
value	B : 

6seqclassifier/encoder/bidirectional_rnn/fw/fw/concat_1ConcatV28seqclassifier/encoder/bidirectional_rnn/fw/fw/ExpandDims5seqclassifier/encoder/bidirectional_rnn/fw/fw/Const_1;seqclassifier/encoder/bidirectional_rnn/fw/fw/concat_1/axis*
T0*
N*
_output_shapes
:
~
9seqclassifier/encoder/bidirectional_rnn/fw/fw/zeros/ConstConst*
valueB
 *    *
dtype0*
_output_shapes
: 
á
3seqclassifier/encoder/bidirectional_rnn/fw/fw/zerosFill6seqclassifier/encoder/bidirectional_rnn/fw/fw/concat_19seqclassifier/encoder/bidirectional_rnn/fw/fw/zeros/Const*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0

5seqclassifier/encoder/bidirectional_rnn/fw/fw/Const_2Const*
valueB: *
dtype0*
_output_shapes
:
Ë
1seqclassifier/encoder/bidirectional_rnn/fw/fw/MinMin9seqclassifier/encoder/bidirectional_rnn/fw/fw/CheckSeqLen5seqclassifier/encoder/bidirectional_rnn/fw/fw/Const_2*
_output_shapes
: *
T0

5seqclassifier/encoder/bidirectional_rnn/fw/fw/Const_3Const*
valueB: *
dtype0*
_output_shapes
:
Ë
1seqclassifier/encoder/bidirectional_rnn/fw/fw/MaxMax9seqclassifier/encoder/bidirectional_rnn/fw/fw/CheckSeqLen5seqclassifier/encoder/bidirectional_rnn/fw/fw/Const_3*
_output_shapes
: *
T0
t
2seqclassifier/encoder/bidirectional_rnn/fw/fw/timeConst*
dtype0*
_output_shapes
: *
value	B : 
Ö
9seqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayTensorArrayV3=seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_1*
dtype0*
_output_shapes

:: *%
element_shape:ÿÿÿÿÿÿÿÿÿú*
identical_element_shapes(*Y
tensor_array_nameDBseqclassifier/encoder/bidirectional_rnn/fw/fw/dynamic_rnn/output_0
×
;seqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArray_1TensorArrayV3=seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_1*
dtype0*
_output_shapes

:: *%
element_shape:ÿÿÿÿÿÿÿÿÿÐ*X
tensor_array_nameCAseqclassifier/encoder/bidirectional_rnn/fw/fw/dynamic_rnn/input_0*
identical_element_shapes(
­
Fseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/ShapeShape7seqclassifier/encoder/bidirectional_rnn/fw/fw/transpose*
_output_shapes
:*
T0

Tseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/strided_slice/stackConst*
dtype0*
_output_shapes
:*
valueB: 
 
Vseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/strided_slice/stack_1Const*
dtype0*
_output_shapes
:*
valueB:
 
Vseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/strided_slice/stack_2Const*
valueB:*
dtype0*
_output_shapes
:
ò
Nseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/strided_sliceStridedSliceFseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/ShapeTseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/strided_slice/stackVseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/strided_slice/stack_1Vseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/strided_slice/stack_2*
_output_shapes
: *
shrink_axis_mask*
Index0*
T0

Lseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/range/startConst*
value	B : *
dtype0*
_output_shapes
: 

Lseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/range/deltaConst*
dtype0*
_output_shapes
: *
value	B :
à
Fseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/rangeRangeLseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/range/startNseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/strided_sliceLseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/range/delta*#
_output_shapes
:ÿÿÿÿÿÿÿÿÿ
ê
hseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/TensorArrayScatter/TensorArrayScatterV3TensorArrayScatterV3;seqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArray_1Fseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/range7seqclassifier/encoder/bidirectional_rnn/fw/fw/transpose=seqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArray_1:1*
T0*J
_class@
><loc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/transpose*
_output_shapes
: 
y
7seqclassifier/encoder/bidirectional_rnn/fw/fw/Maximum/xConst*
value	B :*
dtype0*
_output_shapes
: 
Í
5seqclassifier/encoder/bidirectional_rnn/fw/fw/MaximumMaximum7seqclassifier/encoder/bidirectional_rnn/fw/fw/Maximum/x1seqclassifier/encoder/bidirectional_rnn/fw/fw/Max*
T0*
_output_shapes
: 
×
5seqclassifier/encoder/bidirectional_rnn/fw/fw/MinimumMinimum=seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_15seqclassifier/encoder/bidirectional_rnn/fw/fw/Maximum*
T0*
_output_shapes
: 

Eseqclassifier/encoder/bidirectional_rnn/fw/fw/while/iteration_counterConst*
value	B : *
dtype0*
_output_shapes
: 

9seqclassifier/encoder/bidirectional_rnn/fw/fw/while/EnterEnterEseqclassifier/encoder/bidirectional_rnn/fw/fw/while/iteration_counter*
parallel_iterations *
_output_shapes
: *Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/fw/fw/while/while_context*
T0

;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_1Enter2seqclassifier/encoder/bidirectional_rnn/fw/fw/time*
parallel_iterations *
_output_shapes
: *Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/fw/fw/while/while_context*
T0

;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_2Enter;seqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArray:1*
parallel_iterations *
_output_shapes
: *Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/fw/fw/while/while_context*
T0
Â
;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_3Enter[seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/zeros*
T0*
parallel_iterations *(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/fw/fw/while/while_context
Ä
;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_4Enter]seqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/LSTMCellZeroState/zeros_1*
parallel_iterations *(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/fw/fw/while/while_context*
T0
Û
;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_5Entertseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/zeros*
T0*
parallel_iterations *(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/fw/fw/while/while_context
Ý
;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_6Entervseqclassifier/encoder/bidirectional_rnn/fw/fw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/zeros_1*
parallel_iterations *(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/fw/fw/while/while_context*
T0
ì
9seqclassifier/encoder/bidirectional_rnn/fw/fw/while/MergeMerge9seqclassifier/encoder/bidirectional_rnn/fw/fw/while/EnterAseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration*
N*
_output_shapes
: : *
T0
ò
;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_1Merge;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_1Cseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration_1*
T0*
N*
_output_shapes
: : 
ò
;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_2Merge;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_2Cseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration_2*
N*
_output_shapes
: : *
T0

;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_3Merge;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_3Cseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration_3*
T0*
N**
_output_shapes
:ÿÿÿÿÿÿÿÿÿú: 

;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_4Merge;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_4Cseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration_4*
T0*
N**
_output_shapes
:ÿÿÿÿÿÿÿÿÿú: 

;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_5Merge;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_5Cseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration_5*
N**
_output_shapes
:ÿÿÿÿÿÿÿÿÿú: *
T0

;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_6Merge;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_6Cseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration_6*
N**
_output_shapes
:ÿÿÿÿÿÿÿÿÿú: *
T0
Ü
8seqclassifier/encoder/bidirectional_rnn/fw/fw/while/LessLess9seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Less/Enter*
_output_shapes
: *
T0
¨
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Less/EnterEnter=seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_1*
parallel_iterations *
_output_shapes
: *Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/fw/fw/while/while_context*
T0*
is_constant(
â
:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Less_1Less;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_1@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Less_1/Enter*
T0*
_output_shapes
: 
¢
@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Less_1/EnterEnter5seqclassifier/encoder/bidirectional_rnn/fw/fw/Minimum*
T0*
is_constant(*
parallel_iterations *
_output_shapes
: *Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/fw/fw/while/while_context
Ú
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/LogicalAnd
LogicalAnd8seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Less:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Less_1*
_output_shapes
: 
 
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/LoopCondLoopCond>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/LogicalAnd*
_output_shapes
: 
®
:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/SwitchSwitch9seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/LoopCond*
T0*L
_classB
@>loc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge*
_output_shapes
: : 
´
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_1Switch;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_1<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/LoopCond*
T0*N
_classD
B@loc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_1*
_output_shapes
: : 
´
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_2Switch;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_2<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/LoopCond*
T0*N
_classD
B@loc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_2*
_output_shapes
: : 
Ø
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_3Switch;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_3<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/LoopCond*<
_output_shapes*
(:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú*
T0*N
_classD
B@loc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_3
Ø
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_4Switch;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_4<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/LoopCond*<
_output_shapes*
(:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú*
T0*N
_classD
B@loc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_4
Ø
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_5Switch;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_5<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/LoopCond*
T0*N
_classD
B@loc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_5*<
_output_shapes*
(:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú
Ø
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_6Switch;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_6<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/LoopCond*
T0*N
_classD
B@loc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_6*<
_output_shapes*
(:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú
§
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/IdentityIdentity<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch:1*
_output_shapes
: *
T0
«
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_1Identity>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_1:1*
T0*
_output_shapes
: 
«
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_2Identity>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_2:1*
T0*
_output_shapes
: 
½
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_3Identity>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_3:1*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
½
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_4Identity>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_4:1*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
½
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_5Identity>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_5:1*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
½
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_6Identity>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_6:1*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
º
9seqclassifier/encoder/bidirectional_rnn/fw/fw/while/add/yConst=^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity*
dtype0*
_output_shapes
: *
value	B :
Ø
7seqclassifier/encoder/bidirectional_rnn/fw/fw/while/addAdd<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity9seqclassifier/encoder/bidirectional_rnn/fw/fw/while/add/y*
T0*
_output_shapes
: 
í
Eseqclassifier/encoder/bidirectional_rnn/fw/fw/while/TensorArrayReadV3TensorArrayReadV3Kseqclassifier/encoder/bidirectional_rnn/fw/fw/while/TensorArrayReadV3/Enter>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_1Mseqclassifier/encoder/bidirectional_rnn/fw/fw/while/TensorArrayReadV3/Enter_1*
dtype0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿÐ
·
Kseqclassifier/encoder/bidirectional_rnn/fw/fw/while/TensorArrayReadV3/EnterEnter;seqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArray_1*
parallel_iterations *
_output_shapes
:*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/fw/fw/while/while_context*
T0*
is_constant(
â
Mseqclassifier/encoder/bidirectional_rnn/fw/fw/while/TensorArrayReadV3/Enter_1Enterhseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/TensorArrayScatter/TensorArrayScatterV3*
T0*
is_constant(*
parallel_iterations *
_output_shapes
: *Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/fw/fw/while/while_context

@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/GreaterEqualGreaterEqual>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_1Fseqclassifier/encoder/bidirectional_rnn/fw/fw/while/GreaterEqual/Enter*
T0*#
_output_shapes
:ÿÿÿÿÿÿÿÿÿ
¹
Fseqclassifier/encoder/bidirectional_rnn/fw/fw/while/GreaterEqual/EnterEnter9seqclassifier/encoder/bidirectional_rnn/fw/fw/CheckSeqLen*
T0*
is_constant(*
parallel_iterations *#
_output_shapes
:ÿÿÿÿÿÿÿÿÿ*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/fw/fw/while/while_context
©
rseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/shapeConst*
dtype0*
_output_shapes
:*
valueB"J  è  *d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel

pseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/minConst*
dtype0*
_output_shapes
: *
valueB
 *ÊN½*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel

pseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/maxConst*
valueB
 *ÊN=*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel*
dtype0*
_output_shapes
: 

zseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/RandomUniformRandomUniformrseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/shape*
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel*
dtype0* 
_output_shapes
:
Ê
è
â
pseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/subSubpseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/maxpseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/min*
_output_shapes
: *
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel
ö
pseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/mulMulzseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/RandomUniformpseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/sub* 
_output_shapes
:
Ê
è*
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel
è
lseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniformAddpseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/mulpseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/min*
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel* 
_output_shapes
:
Ê
è

Qseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel
VariableV2*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel*
dtype0* 
_output_shapes
:
Ê
è*
shape:
Ê
è
´
Xseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/AssignAssignQseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernellseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform*
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel* 
_output_shapes
:
Ê
è
à
Vseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/readIdentityQseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel*
T0* 
_output_shapes
:
Ê
è
 
qseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias/Initializer/zeros/shape_as_tensorConst*
dtype0*
_output_shapes
:*
valueB:è*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias

gseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias/Initializer/zeros/ConstConst*
valueB
 *    *b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias*
dtype0*
_output_shapes
: 
Ï
aseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias/Initializer/zerosFillqseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias/Initializer/zeros/shape_as_tensorgseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias/Initializer/zeros/Const*
T0*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias*
_output_shapes	
:è
ý
Oseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias
VariableV2*
dtype0*
_output_shapes	
:è*
shape:è*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias

Vseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias/AssignAssignOseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/biasaseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias/Initializer/zeros*
T0*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias*
_output_shapes	
:è
×
Tseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias/readIdentityOseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias*
_output_shapes	
:è*
T0
ã
bseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/concat/axisConst=^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity*
dtype0*
_output_shapes
: *
value	B :

]seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/concatConcatV2Eseqclassifier/encoder/bidirectional_rnn/fw/fw/while/TensorArrayReadV3>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_4bseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/concat/axis*
T0*
N*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿÊ

Þ
]seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/MatMulMatMul]seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/concatcseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/MatMul/Enter*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿè*
T0
ð
cseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/MatMul/EnterEnterVseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/read*
parallel_iterations * 
_output_shapes
:
Ê
è*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/fw/fw/while/while_context*
T0*
is_constant(
á
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/BiasAddBiasAdd]seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/MatMuldseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/BiasAdd/Enter*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿè*
T0
ê
dseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/BiasAdd/EnterEnterTseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias/read*
T0*
is_constant(*
parallel_iterations *
_output_shapes	
:è*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/fw/fw/while/while_context
Ý
\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/ConstConst=^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity*
dtype0*
_output_shapes
: *
value	B :
ç
fseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/split/split_dimConst=^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity*
dtype0*
_output_shapes
: *
value	B :
­
\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/splitSplitfseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/split/split_dim^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/BiasAdd*d
_output_shapesR
P:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú*
	num_split*
T0
à
\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/add/yConst=^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity*
valueB
 *  ?*
dtype0*
_output_shapes
: 
Ò
Zseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/addAdd^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/split:2\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/add/y*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
ø
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/SigmoidSigmoidZseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/add*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
´
Zseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/mulMul^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/Sigmoid>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_3*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
ü
`seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/Sigmoid_1Sigmoid\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/split*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
ö
[seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/TanhTanh^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/split:1*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
Õ
\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/mul_1Mul`seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/Sigmoid_1[seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/Tanh*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
Ð
\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/add_1AddZseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/mul\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/mul_1*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
þ
`seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/Sigmoid_2Sigmoid^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/split:3*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
ö
]seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/Tanh_1Tanh\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/add_1*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
×
\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/mul_2Mul`seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/Sigmoid_2]seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/Tanh_1*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
©
rseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/shapeConst*
dtype0*
_output_shapes
:*
valueB"ô  è  *d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel

pseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/minConst*
dtype0*
_output_shapes
: *
valueB
 *â½*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel

pseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/maxConst*
dtype0*
_output_shapes
: *
valueB
 *â=*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel

zseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/RandomUniformRandomUniformrseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/shape*
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel*
dtype0* 
_output_shapes
:
ôè
â
pseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/subSubpseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/maxpseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/min*
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel*
_output_shapes
: 
ö
pseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/mulMulzseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/RandomUniformpseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/sub* 
_output_shapes
:
ôè*
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel
è
lseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniformAddpseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/mulpseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/min*
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel* 
_output_shapes
:
ôè
æ
Qseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernelVarHandleOp*b
shared_nameSQseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel*
dtype0*
_output_shapes
: *
shape:
ôè
ó
rseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/IsInitialized/VarIsInitializedOpVarIsInitializedOpQseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel*
_output_shapes
: 
 
Xseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/AssignAssignVariableOpQseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernellseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel*
dtype0
ß
eseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Read/ReadVariableOpReadVariableOpQseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel*
dtype0* 
_output_shapes
:
ôè*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel
ý
_seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Read/IdentityIdentityeseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Read/ReadVariableOp* 
_output_shapes
:
ôè*
T0
 
qseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/Initializer/zeros/shape_as_tensorConst*
valueB:è*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias*
dtype0*
_output_shapes
:

gseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/Initializer/zeros/ConstConst*
valueB
 *    *b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias*
dtype0*
_output_shapes
: 
Ï
aseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/Initializer/zerosFillqseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/Initializer/zeros/shape_as_tensorgseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/Initializer/zeros/Const*
_output_shapes	
:è*
T0*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias
Û
Oseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/biasVarHandleOp*`
shared_nameQOseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias*
dtype0*
_output_shapes
: *
shape:è
ï
pseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/IsInitialized/VarIsInitializedOpVarIsInitializedOpOseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias*
_output_shapes
: 

Vseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/AssignAssignVariableOpOseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/biasaseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/Initializer/zeros*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias*
dtype0
Ô
cseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/Read/ReadVariableOpReadVariableOpOseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias*
dtype0*
_output_shapes	
:è*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias
ô
]seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/Read/IdentityIdentitycseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/Read/ReadVariableOp*
_output_shapes	
:è*
T0
ã
bseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/concat/axisConst=^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity*
dtype0*
_output_shapes
: *
value	B :
§
]seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/concatConcatV2\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/mul_2>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_6bseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/concat/axis*
T0*
N*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿô
Þ
]seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/MatMulMatMul]seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/concatcseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/MatMul/Enter*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿè*
T0
ù
cseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/MatMul/EnterEnter_seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Read/Identity*
T0*
is_constant(*
parallel_iterations * 
_output_shapes
:
ôè*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/fw/fw/while/while_context
á
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/BiasAddBiasAdd]seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/MatMuldseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/BiasAdd/Enter*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿè
ó
dseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/BiasAdd/EnterEnter]seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/Read/Identity*
parallel_iterations *
_output_shapes	
:è*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/fw/fw/while/while_context*
T0*
is_constant(
Ý
\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/ConstConst=^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity*
value	B :*
dtype0*
_output_shapes
: 
ç
fseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/split/split_dimConst=^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity*
dtype0*
_output_shapes
: *
value	B :
­
\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/splitSplitfseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/split/split_dim^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/BiasAdd*d
_output_shapesR
P:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú*
	num_split*
T0
à
\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/add/yConst=^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity*
valueB
 *  ?*
dtype0*
_output_shapes
: 
Ò
Zseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/addAdd^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/split:2\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/add/y*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
ø
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/SigmoidSigmoidZseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/add*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
´
Zseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/mulMul^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/Sigmoid>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_5*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
ü
`seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/Sigmoid_1Sigmoid\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/split*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
ö
[seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/TanhTanh^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/split:1*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
Õ
\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/mul_1Mul`seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/Sigmoid_1[seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/Tanh*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
Ð
\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/add_1AddZseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/mul\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/mul_1*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
þ
`seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/Sigmoid_2Sigmoid^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/split:3*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
ö
]seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/Tanh_1Tanh\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/add_1*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
×
\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/mul_2Mul`seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/Sigmoid_2]seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/Tanh_1*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
Æ
Pseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/addAdd\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/mul_2\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/mul_2*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
²
:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/SelectSelect@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/GreaterEqual@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Select/EnterPseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/add*
T0*c
_classY
WUloc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/add*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú

@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Select/EnterEnter3seqclassifier/encoder/bidirectional_rnn/fw/fw/zeros*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/fw/fw/while/while_context*
T0*c
_classY
WUloc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/add*
parallel_iterations *
is_constant(
Ê
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Select_1Select@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/GreaterEqual>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_3\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/add_1*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0*o
_classe
caloc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/add_1
Ê
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Select_2Select@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/GreaterEqual>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_4\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/mul_2*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0*o
_classe
caloc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/mul_2
Ê
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Select_3Select@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/GreaterEqual>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_5\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/add_1*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0*o
_classe
caloc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/add_1
Ê
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Select_4Select@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/GreaterEqual>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_6\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/mul_2*
T0*o
_classe
caloc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/mul_2*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú

Wseqclassifier/encoder/bidirectional_rnn/fw/fw/while/TensorArrayWrite/TensorArrayWriteV3TensorArrayWriteV3]seqclassifier/encoder/bidirectional_rnn/fw/fw/while/TensorArrayWrite/TensorArrayWriteV3/Enter>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_1:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Select>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_2*
_output_shapes
: *
T0*c
_classY
WUloc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/add
¬
]seqclassifier/encoder/bidirectional_rnn/fw/fw/while/TensorArrayWrite/TensorArrayWriteV3/EnterEnter9seqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArray*
T0*c
_classY
WUloc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/add*
parallel_iterations *
is_constant(*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/fw/fw/while/while_context*
_output_shapes
:
¼
;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/add_1/yConst=^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity*
dtype0*
_output_shapes
: *
value	B :
Þ
9seqclassifier/encoder/bidirectional_rnn/fw/fw/while/add_1Add>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_1;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/add_1/y*
_output_shapes
: *
T0
¬
Aseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIterationNextIteration7seqclassifier/encoder/bidirectional_rnn/fw/fw/while/add*
T0*
_output_shapes
: 
°
Cseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration_1NextIteration9seqclassifier/encoder/bidirectional_rnn/fw/fw/while/add_1*
_output_shapes
: *
T0
Î
Cseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration_2NextIterationWseqclassifier/encoder/bidirectional_rnn/fw/fw/while/TensorArrayWrite/TensorArrayWriteV3*
_output_shapes
: *
T0
Å
Cseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration_3NextIteration<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Select_1*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
Å
Cseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration_4NextIteration<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Select_2*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
Å
Cseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration_5NextIteration<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Select_3*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
Å
Cseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration_6NextIteration<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Select_4*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú

8seqclassifier/encoder/bidirectional_rnn/fw/fw/while/ExitExit:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch*
_output_shapes
: *
T0
¡
:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_1Exit<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_1*
T0*
_output_shapes
: 
¡
:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_2Exit<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_2*
T0*
_output_shapes
: 
³
:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_3Exit<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_3*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
³
:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_4Exit<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_4*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
³
:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_5Exit<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_5*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
³
:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_6Exit<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_6*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
Â
Pseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayStack/TensorArraySizeV3TensorArraySizeV39seqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArray:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_2*L
_classB
@>loc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArray*
_output_shapes
: 
Ú
Jseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayStack/range/startConst*
dtype0*
_output_shapes
: *
value	B : *L
_classB
@>loc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArray
Ú
Jseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayStack/range/deltaConst*
value	B :*L
_classB
@>loc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArray*
dtype0*
_output_shapes
: 
ª
Dseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayStack/rangeRangeJseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayStack/range/startPseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayStack/TensorArraySizeV3Jseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayStack/range/delta*L
_classB
@>loc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArray*#
_output_shapes
:ÿÿÿÿÿÿÿÿÿ
ß
Rseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayStack/TensorArrayGatherV3TensorArrayGatherV39seqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayDseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayStack/range:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_2*
dtype0*5
_output_shapes#
!:ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿú*%
element_shape:ÿÿÿÿÿÿÿÿÿú*L
_classB
@>loc:@seqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArray

5seqclassifier/encoder/bidirectional_rnn/fw/fw/Const_4Const*
valueB:ú*
dtype0*
_output_shapes
:
v
4seqclassifier/encoder/bidirectional_rnn/fw/fw/Rank_1Const*
value	B :*
dtype0*
_output_shapes
: 
}
;seqclassifier/encoder/bidirectional_rnn/fw/fw/range_1/startConst*
value	B :*
dtype0*
_output_shapes
: 
}
;seqclassifier/encoder/bidirectional_rnn/fw/fw/range_1/deltaConst*
value	B :*
dtype0*
_output_shapes
: 

5seqclassifier/encoder/bidirectional_rnn/fw/fw/range_1Range;seqclassifier/encoder/bidirectional_rnn/fw/fw/range_1/start4seqclassifier/encoder/bidirectional_rnn/fw/fw/Rank_1;seqclassifier/encoder/bidirectional_rnn/fw/fw/range_1/delta*
_output_shapes
:

?seqclassifier/encoder/bidirectional_rnn/fw/fw/concat_2/values_0Const*
dtype0*
_output_shapes
:*
valueB"       
}
;seqclassifier/encoder/bidirectional_rnn/fw/fw/concat_2/axisConst*
value	B : *
dtype0*
_output_shapes
: 
¥
6seqclassifier/encoder/bidirectional_rnn/fw/fw/concat_2ConcatV2?seqclassifier/encoder/bidirectional_rnn/fw/fw/concat_2/values_05seqclassifier/encoder/bidirectional_rnn/fw/fw/range_1;seqclassifier/encoder/bidirectional_rnn/fw/fw/concat_2/axis*
T0*
N*
_output_shapes
:

9seqclassifier/encoder/bidirectional_rnn/fw/fw/transpose_1	TransposeRseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayStack/TensorArrayGatherV36seqclassifier/encoder/bidirectional_rnn/fw/fw/concat_2*
T0*5
_output_shapes#
!:ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿú
Ò
:seqclassifier/encoder/bidirectional_rnn/bw/ReverseSequenceReverseSequenceseqclassifier/encoder/concat_2numWords*
T0*
seq_dim*5
_output_shapes#
!:ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÐ*

Tlen0
t
2seqclassifier/encoder/bidirectional_rnn/bw/bw/RankConst*
dtype0*
_output_shapes
: *
value	B :
{
9seqclassifier/encoder/bidirectional_rnn/bw/bw/range/startConst*
value	B :*
dtype0*
_output_shapes
: 
{
9seqclassifier/encoder/bidirectional_rnn/bw/bw/range/deltaConst*
value	B :*
dtype0*
_output_shapes
: 

3seqclassifier/encoder/bidirectional_rnn/bw/bw/rangeRange9seqclassifier/encoder/bidirectional_rnn/bw/bw/range/start2seqclassifier/encoder/bidirectional_rnn/bw/bw/Rank9seqclassifier/encoder/bidirectional_rnn/bw/bw/range/delta*
_output_shapes
:

=seqclassifier/encoder/bidirectional_rnn/bw/bw/concat/values_0Const*
dtype0*
_output_shapes
:*
valueB"       
{
9seqclassifier/encoder/bidirectional_rnn/bw/bw/concat/axisConst*
value	B : *
dtype0*
_output_shapes
: 

4seqclassifier/encoder/bidirectional_rnn/bw/bw/concatConcatV2=seqclassifier/encoder/bidirectional_rnn/bw/bw/concat/values_03seqclassifier/encoder/bidirectional_rnn/bw/bw/range9seqclassifier/encoder/bidirectional_rnn/bw/bw/concat/axis*
T0*
N*
_output_shapes
:
ö
7seqclassifier/encoder/bidirectional_rnn/bw/bw/transpose	Transpose:seqclassifier/encoder/bidirectional_rnn/bw/ReverseSequence4seqclassifier/encoder/bidirectional_rnn/bw/bw/concat*
T0*5
_output_shapes#
!:ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÐ

=seqclassifier/encoder/bidirectional_rnn/bw/bw/sequence_lengthIdentitynumWords*
T0*#
_output_shapes
:ÿÿÿÿÿÿÿÿÿ

3seqclassifier/encoder/bidirectional_rnn/bw/bw/ShapeShape7seqclassifier/encoder/bidirectional_rnn/bw/bw/transpose*
_output_shapes
:*
T0

Aseqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice/stackConst*
valueB:*
dtype0*
_output_shapes
:

Cseqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice/stack_1Const*
dtype0*
_output_shapes
:*
valueB:

Cseqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice/stack_2Const*
dtype0*
_output_shapes
:*
valueB:

;seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_sliceStridedSlice3seqclassifier/encoder/bidirectional_rnn/bw/bw/ShapeAseqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice/stackCseqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice/stack_1Cseqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice/stack_2*
_output_shapes
: *
shrink_axis_mask*
T0*
Index0
¦
dseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims/dimConst*
dtype0*
_output_shapes
: *
value	B : 
¶
`seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims
ExpandDims;seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slicedseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims/dim*
T0*
_output_shapes
:
¦
[seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/ConstConst*
valueB:ú*
dtype0*
_output_shapes
:
£
aseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/concat/axisConst*
dtype0*
_output_shapes
: *
value	B : 
¸
\seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/concatConcatV2`seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims[seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/Constaseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/concat/axis*
N*
_output_shapes
:*
T0
¦
aseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/zeros/ConstConst*
dtype0*
_output_shapes
: *
valueB
 *    
×
[seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/zerosFill\seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/concataseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/zeros/Const*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
¨
fseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_1/dimConst*
dtype0*
_output_shapes
: *
value	B : 
º
bseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_1
ExpandDims;seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slicefseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_1/dim*
_output_shapes
:*
T0
¨
]seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/Const_1Const*
dtype0*
_output_shapes
:*
valueB:ú
¨
fseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_2/dimConst*
value	B : *
dtype0*
_output_shapes
: 
º
bseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_2
ExpandDims;seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slicefseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_2/dim*
_output_shapes
:*
T0
¨
]seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/Const_2Const*
valueB:ú*
dtype0*
_output_shapes
:
¥
cseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/concat_1/axisConst*
dtype0*
_output_shapes
: *
value	B : 
À
^seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/concat_1ConcatV2bseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_2]seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/Const_2cseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/concat_1/axis*
T0*
N*
_output_shapes
:
¨
cseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/zeros_1/ConstConst*
valueB
 *    *
dtype0*
_output_shapes
: 
Ý
]seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/zeros_1Fill^seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/concat_1cseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/zeros_1/Const*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
¨
fseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_3/dimConst*
value	B : *
dtype0*
_output_shapes
: 
º
bseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_3
ExpandDims;seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slicefseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/ExpandDims_3/dim*
_output_shapes
:*
T0
¨
]seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/Const_3Const*
valueB:ú*
dtype0*
_output_shapes
:
¿
}seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims/dimConst*
value	B : *
dtype0*
_output_shapes
: 
è
yseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims
ExpandDims;seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice}seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims/dim*
T0*
_output_shapes
:
¿
tseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ConstConst*
valueB:ú*
dtype0*
_output_shapes
:
¼
zseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/concat/axisConst*
value	B : *
dtype0*
_output_shapes
: 

useqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/concatConcatV2yseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDimstseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/Constzseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/concat/axis*
N*
_output_shapes
:*
T0
¿
zseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/zeros/ConstConst*
dtype0*
_output_shapes
: *
valueB
 *    
¢
tseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/zerosFilluseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/concatzseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/zeros/Const*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
Á
seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_1/dimConst*
dtype0*
_output_shapes
: *
value	B : 
ì
{seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_1
ExpandDims;seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_sliceseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_1/dim*
T0*
_output_shapes
:
Á
vseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/Const_1Const*
dtype0*
_output_shapes
:*
valueB:ú
Á
seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_2/dimConst*
dtype0*
_output_shapes
: *
value	B : 
ì
{seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_2
ExpandDims;seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_sliceseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_2/dim*
T0*
_output_shapes
:
Á
vseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/Const_2Const*
dtype0*
_output_shapes
:*
valueB:ú
¾
|seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/concat_1/axisConst*
value	B : *
dtype0*
_output_shapes
: 
¤
wseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/concat_1ConcatV2{seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_2vseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/Const_2|seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/concat_1/axis*
N*
_output_shapes
:*
T0
Á
|seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/zeros_1/ConstConst*
dtype0*
_output_shapes
: *
valueB
 *    
¨
vseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/zeros_1Fillwseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/concat_1|seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/zeros_1/Const*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
Á
seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_3/dimConst*
dtype0*
_output_shapes
: *
value	B : 
ì
{seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_3
ExpandDims;seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_sliceseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/ExpandDims_3/dim*
_output_shapes
:*
T0
Á
vseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/Const_3Const*
valueB:ú*
dtype0*
_output_shapes
:
¢
5seqclassifier/encoder/bidirectional_rnn/bw/bw/Shape_1Shape=seqclassifier/encoder/bidirectional_rnn/bw/bw/sequence_length*
_output_shapes
:*
T0
¦
3seqclassifier/encoder/bidirectional_rnn/bw/bw/stackPack;seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice*
N*
_output_shapes
:*
T0
Í
3seqclassifier/encoder/bidirectional_rnn/bw/bw/EqualEqual5seqclassifier/encoder/bidirectional_rnn/bw/bw/Shape_13seqclassifier/encoder/bidirectional_rnn/bw/bw/stack*
T0*
_output_shapes
:
}
3seqclassifier/encoder/bidirectional_rnn/bw/bw/ConstConst*
valueB: *
dtype0*
_output_shapes
:
º
1seqclassifier/encoder/bidirectional_rnn/bw/bw/AllAll3seqclassifier/encoder/bidirectional_rnn/bw/bw/Equal3seqclassifier/encoder/bidirectional_rnn/bw/bw/Const*
_output_shapes
: 
Ø
:seqclassifier/encoder/bidirectional_rnn/bw/bw/Assert/ConstConst*
dtype0*
_output_shapes
: *n
valueeBc B]Expected shape for Tensor seqclassifier/encoder/bidirectional_rnn/bw/bw/sequence_length:0 is 

<seqclassifier/encoder/bidirectional_rnn/bw/bw/Assert/Const_1Const*!
valueB B but saw shape: *
dtype0*
_output_shapes
: 
à
Bseqclassifier/encoder/bidirectional_rnn/bw/bw/Assert/Assert/data_0Const*n
valueeBc B]Expected shape for Tensor seqclassifier/encoder/bidirectional_rnn/bw/bw/sequence_length:0 is *
dtype0*
_output_shapes
: 

Bseqclassifier/encoder/bidirectional_rnn/bw/bw/Assert/Assert/data_2Const*
dtype0*
_output_shapes
: *!
valueB B but saw shape: 
û
;seqclassifier/encoder/bidirectional_rnn/bw/bw/Assert/AssertAssert1seqclassifier/encoder/bidirectional_rnn/bw/bw/AllBseqclassifier/encoder/bidirectional_rnn/bw/bw/Assert/Assert/data_03seqclassifier/encoder/bidirectional_rnn/bw/bw/stackBseqclassifier/encoder/bidirectional_rnn/bw/bw/Assert/Assert/data_25seqclassifier/encoder/bidirectional_rnn/bw/bw/Shape_1*
T
2
ð
9seqclassifier/encoder/bidirectional_rnn/bw/bw/CheckSeqLenIdentity=seqclassifier/encoder/bidirectional_rnn/bw/bw/sequence_length<^seqclassifier/encoder/bidirectional_rnn/bw/bw/Assert/Assert*
T0*#
_output_shapes
:ÿÿÿÿÿÿÿÿÿ

5seqclassifier/encoder/bidirectional_rnn/bw/bw/Shape_2Shape7seqclassifier/encoder/bidirectional_rnn/bw/bw/transpose*
_output_shapes
:*
T0

Cseqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_1/stackConst*
valueB: *
dtype0*
_output_shapes
:

Eseqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_1/stack_1Const*
dtype0*
_output_shapes
:*
valueB:

Eseqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_1/stack_2Const*
dtype0*
_output_shapes
:*
valueB:

=seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_1StridedSlice5seqclassifier/encoder/bidirectional_rnn/bw/bw/Shape_2Cseqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_1/stackEseqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_1/stack_1Eseqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_1/stack_2*
_output_shapes
: *
shrink_axis_mask*
T0*
Index0

5seqclassifier/encoder/bidirectional_rnn/bw/bw/Shape_3Shape7seqclassifier/encoder/bidirectional_rnn/bw/bw/transpose*
T0*
_output_shapes
:

Cseqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_2/stackConst*
dtype0*
_output_shapes
:*
valueB:

Eseqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_2/stack_1Const*
valueB:*
dtype0*
_output_shapes
:

Eseqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_2/stack_2Const*
valueB:*
dtype0*
_output_shapes
:

=seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_2StridedSlice5seqclassifier/encoder/bidirectional_rnn/bw/bw/Shape_3Cseqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_2/stackEseqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_2/stack_1Eseqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_2/stack_2*
_output_shapes
: *
shrink_axis_mask*
T0*
Index0
~
<seqclassifier/encoder/bidirectional_rnn/bw/bw/ExpandDims/dimConst*
value	B : *
dtype0*
_output_shapes
: 
è
8seqclassifier/encoder/bidirectional_rnn/bw/bw/ExpandDims
ExpandDims=seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_2<seqclassifier/encoder/bidirectional_rnn/bw/bw/ExpandDims/dim*
T0*
_output_shapes
:

5seqclassifier/encoder/bidirectional_rnn/bw/bw/Const_1Const*
valueB:ú*
dtype0*
_output_shapes
:
}
;seqclassifier/encoder/bidirectional_rnn/bw/bw/concat_1/axisConst*
value	B : *
dtype0*
_output_shapes
: 

6seqclassifier/encoder/bidirectional_rnn/bw/bw/concat_1ConcatV28seqclassifier/encoder/bidirectional_rnn/bw/bw/ExpandDims5seqclassifier/encoder/bidirectional_rnn/bw/bw/Const_1;seqclassifier/encoder/bidirectional_rnn/bw/bw/concat_1/axis*
N*
_output_shapes
:*
T0
~
9seqclassifier/encoder/bidirectional_rnn/bw/bw/zeros/ConstConst*
valueB
 *    *
dtype0*
_output_shapes
: 
á
3seqclassifier/encoder/bidirectional_rnn/bw/bw/zerosFill6seqclassifier/encoder/bidirectional_rnn/bw/bw/concat_19seqclassifier/encoder/bidirectional_rnn/bw/bw/zeros/Const*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú

5seqclassifier/encoder/bidirectional_rnn/bw/bw/Const_2Const*
valueB: *
dtype0*
_output_shapes
:
Ë
1seqclassifier/encoder/bidirectional_rnn/bw/bw/MinMin9seqclassifier/encoder/bidirectional_rnn/bw/bw/CheckSeqLen5seqclassifier/encoder/bidirectional_rnn/bw/bw/Const_2*
_output_shapes
: *
T0

5seqclassifier/encoder/bidirectional_rnn/bw/bw/Const_3Const*
dtype0*
_output_shapes
:*
valueB: 
Ë
1seqclassifier/encoder/bidirectional_rnn/bw/bw/MaxMax9seqclassifier/encoder/bidirectional_rnn/bw/bw/CheckSeqLen5seqclassifier/encoder/bidirectional_rnn/bw/bw/Const_3*
_output_shapes
: *
T0
t
2seqclassifier/encoder/bidirectional_rnn/bw/bw/timeConst*
dtype0*
_output_shapes
: *
value	B : 
Ö
9seqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayTensorArrayV3=seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_1*
dtype0*
_output_shapes

:: *%
element_shape:ÿÿÿÿÿÿÿÿÿú*Y
tensor_array_nameDBseqclassifier/encoder/bidirectional_rnn/bw/bw/dynamic_rnn/output_0*
identical_element_shapes(
×
;seqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArray_1TensorArrayV3=seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_1*
dtype0*
_output_shapes

:: *%
element_shape:ÿÿÿÿÿÿÿÿÿÐ*X
tensor_array_nameCAseqclassifier/encoder/bidirectional_rnn/bw/bw/dynamic_rnn/input_0*
identical_element_shapes(
­
Fseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/ShapeShape7seqclassifier/encoder/bidirectional_rnn/bw/bw/transpose*
T0*
_output_shapes
:

Tseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/strided_slice/stackConst*
dtype0*
_output_shapes
:*
valueB: 
 
Vseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/strided_slice/stack_1Const*
valueB:*
dtype0*
_output_shapes
:
 
Vseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/strided_slice/stack_2Const*
dtype0*
_output_shapes
:*
valueB:
ò
Nseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/strided_sliceStridedSliceFseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/ShapeTseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/strided_slice/stackVseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/strided_slice/stack_1Vseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/strided_slice/stack_2*
_output_shapes
: *
shrink_axis_mask*
T0*
Index0

Lseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/range/startConst*
value	B : *
dtype0*
_output_shapes
: 

Lseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/range/deltaConst*
dtype0*
_output_shapes
: *
value	B :
à
Fseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/rangeRangeLseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/range/startNseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/strided_sliceLseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/range/delta*#
_output_shapes
:ÿÿÿÿÿÿÿÿÿ
ê
hseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/TensorArrayScatter/TensorArrayScatterV3TensorArrayScatterV3;seqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArray_1Fseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/range7seqclassifier/encoder/bidirectional_rnn/bw/bw/transpose=seqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArray_1:1*
_output_shapes
: *
T0*J
_class@
><loc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/transpose
y
7seqclassifier/encoder/bidirectional_rnn/bw/bw/Maximum/xConst*
dtype0*
_output_shapes
: *
value	B :
Í
5seqclassifier/encoder/bidirectional_rnn/bw/bw/MaximumMaximum7seqclassifier/encoder/bidirectional_rnn/bw/bw/Maximum/x1seqclassifier/encoder/bidirectional_rnn/bw/bw/Max*
_output_shapes
: *
T0
×
5seqclassifier/encoder/bidirectional_rnn/bw/bw/MinimumMinimum=seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_15seqclassifier/encoder/bidirectional_rnn/bw/bw/Maximum*
_output_shapes
: *
T0

Eseqclassifier/encoder/bidirectional_rnn/bw/bw/while/iteration_counterConst*
value	B : *
dtype0*
_output_shapes
: 

9seqclassifier/encoder/bidirectional_rnn/bw/bw/while/EnterEnterEseqclassifier/encoder/bidirectional_rnn/bw/bw/while/iteration_counter*
T0*
parallel_iterations *
_output_shapes
: *Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/bw/bw/while/while_context

;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_1Enter2seqclassifier/encoder/bidirectional_rnn/bw/bw/time*
T0*
parallel_iterations *
_output_shapes
: *Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/bw/bw/while/while_context

;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_2Enter;seqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArray:1*
parallel_iterations *
_output_shapes
: *Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/bw/bw/while/while_context*
T0
Â
;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_3Enter[seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/zeros*
parallel_iterations *(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/bw/bw/while/while_context*
T0
Ä
;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_4Enter]seqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/LSTMCellZeroState/zeros_1*
parallel_iterations *(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/bw/bw/while/while_context*
T0
Û
;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_5Entertseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/zeros*
T0*
parallel_iterations *(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/bw/bw/while/while_context
Ý
;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_6Entervseqclassifier/encoder/bidirectional_rnn/bw/bw/MultiRNNCellZeroState/ResidualWrapperZeroState/LSTMCellZeroState/zeros_1*
parallel_iterations *(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/bw/bw/while/while_context*
T0
ì
9seqclassifier/encoder/bidirectional_rnn/bw/bw/while/MergeMerge9seqclassifier/encoder/bidirectional_rnn/bw/bw/while/EnterAseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration*
N*
_output_shapes
: : *
T0
ò
;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_1Merge;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_1Cseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration_1*
T0*
N*
_output_shapes
: : 
ò
;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_2Merge;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_2Cseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration_2*
T0*
N*
_output_shapes
: : 

;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_3Merge;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_3Cseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration_3*
N**
_output_shapes
:ÿÿÿÿÿÿÿÿÿú: *
T0

;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_4Merge;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_4Cseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration_4*
N**
_output_shapes
:ÿÿÿÿÿÿÿÿÿú: *
T0

;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_5Merge;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_5Cseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration_5*
T0*
N**
_output_shapes
:ÿÿÿÿÿÿÿÿÿú: 

;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_6Merge;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_6Cseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration_6*
T0*
N**
_output_shapes
:ÿÿÿÿÿÿÿÿÿú: 
Ü
8seqclassifier/encoder/bidirectional_rnn/bw/bw/while/LessLess9seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Less/Enter*
T0*
_output_shapes
: 
¨
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Less/EnterEnter=seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_1*
parallel_iterations *
_output_shapes
: *Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/bw/bw/while/while_context*
T0*
is_constant(
â
:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Less_1Less;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_1@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Less_1/Enter*
T0*
_output_shapes
: 
¢
@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Less_1/EnterEnter5seqclassifier/encoder/bidirectional_rnn/bw/bw/Minimum*
parallel_iterations *
_output_shapes
: *Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/bw/bw/while/while_context*
T0*
is_constant(
Ú
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/LogicalAnd
LogicalAnd8seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Less:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Less_1*
_output_shapes
: 
 
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/LoopCondLoopCond>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/LogicalAnd*
_output_shapes
: 
®
:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/SwitchSwitch9seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/LoopCond*
_output_shapes
: : *
T0*L
_classB
@>loc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge
´
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_1Switch;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_1<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/LoopCond*
_output_shapes
: : *
T0*N
_classD
B@loc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_1
´
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_2Switch;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_2<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/LoopCond*
_output_shapes
: : *
T0*N
_classD
B@loc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_2
Ø
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_3Switch;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_3<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/LoopCond*<
_output_shapes*
(:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú*
T0*N
_classD
B@loc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_3
Ø
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_4Switch;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_4<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/LoopCond*
T0*N
_classD
B@loc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_4*<
_output_shapes*
(:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú
Ø
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_5Switch;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_5<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/LoopCond*<
_output_shapes*
(:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú*
T0*N
_classD
B@loc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_5
Ø
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_6Switch;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_6<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/LoopCond*
T0*N
_classD
B@loc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_6*<
_output_shapes*
(:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú
§
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/IdentityIdentity<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch:1*
_output_shapes
: *
T0
«
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_1Identity>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_1:1*
T0*
_output_shapes
: 
«
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_2Identity>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_2:1*
_output_shapes
: *
T0
½
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_3Identity>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_3:1*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
½
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_4Identity>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_4:1*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
½
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_5Identity>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_5:1*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
½
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_6Identity>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_6:1*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
º
9seqclassifier/encoder/bidirectional_rnn/bw/bw/while/add/yConst=^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity*
value	B :*
dtype0*
_output_shapes
: 
Ø
7seqclassifier/encoder/bidirectional_rnn/bw/bw/while/addAdd<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity9seqclassifier/encoder/bidirectional_rnn/bw/bw/while/add/y*
T0*
_output_shapes
: 
í
Eseqclassifier/encoder/bidirectional_rnn/bw/bw/while/TensorArrayReadV3TensorArrayReadV3Kseqclassifier/encoder/bidirectional_rnn/bw/bw/while/TensorArrayReadV3/Enter>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_1Mseqclassifier/encoder/bidirectional_rnn/bw/bw/while/TensorArrayReadV3/Enter_1*
dtype0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿÐ
·
Kseqclassifier/encoder/bidirectional_rnn/bw/bw/while/TensorArrayReadV3/EnterEnter;seqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArray_1*
T0*
is_constant(*
parallel_iterations *
_output_shapes
:*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/bw/bw/while/while_context
â
Mseqclassifier/encoder/bidirectional_rnn/bw/bw/while/TensorArrayReadV3/Enter_1Enterhseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/TensorArrayScatter/TensorArrayScatterV3*
T0*
is_constant(*
parallel_iterations *
_output_shapes
: *Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/bw/bw/while/while_context

@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/GreaterEqualGreaterEqual>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_1Fseqclassifier/encoder/bidirectional_rnn/bw/bw/while/GreaterEqual/Enter*#
_output_shapes
:ÿÿÿÿÿÿÿÿÿ*
T0
¹
Fseqclassifier/encoder/bidirectional_rnn/bw/bw/while/GreaterEqual/EnterEnter9seqclassifier/encoder/bidirectional_rnn/bw/bw/CheckSeqLen*
parallel_iterations *#
_output_shapes
:ÿÿÿÿÿÿÿÿÿ*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/bw/bw/while/while_context*
T0*
is_constant(
©
rseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/shapeConst*
dtype0*
_output_shapes
:*
valueB"J  è  *d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel

pseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/minConst*
valueB
 *ÊN½*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel*
dtype0*
_output_shapes
: 

pseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/maxConst*
dtype0*
_output_shapes
: *
valueB
 *ÊN=*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel

zseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/RandomUniformRandomUniformrseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/shape*
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel*
dtype0* 
_output_shapes
:
Ê
è
â
pseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/subSubpseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/maxpseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/min*
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel*
_output_shapes
: 
ö
pseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/mulMulzseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/RandomUniformpseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/sub* 
_output_shapes
:
Ê
è*
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel
è
lseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniformAddpseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/mulpseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform/min* 
_output_shapes
:
Ê
è*
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel

Qseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel
VariableV2*
dtype0* 
_output_shapes
:
Ê
è*
shape:
Ê
è*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel
´
Xseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/AssignAssignQseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernellseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform* 
_output_shapes
:
Ê
è*
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel
à
Vseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/readIdentityQseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel*
T0* 
_output_shapes
:
Ê
è
 
qseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias/Initializer/zeros/shape_as_tensorConst*
valueB:è*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias*
dtype0*
_output_shapes
:

gseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias/Initializer/zeros/ConstConst*
valueB
 *    *b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias*
dtype0*
_output_shapes
: 
Ï
aseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias/Initializer/zerosFillqseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias/Initializer/zeros/shape_as_tensorgseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias/Initializer/zeros/Const*
T0*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias*
_output_shapes	
:è
ý
Oseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias
VariableV2*
dtype0*
_output_shapes	
:è*
shape:è*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias

Vseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias/AssignAssignOseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/biasaseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias/Initializer/zeros*
T0*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias*
_output_shapes	
:è
×
Tseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias/readIdentityOseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias*
_output_shapes	
:è*
T0
ã
bseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/concat/axisConst=^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity*
value	B :*
dtype0*
_output_shapes
: 

]seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/concatConcatV2Eseqclassifier/encoder/bidirectional_rnn/bw/bw/while/TensorArrayReadV3>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_4bseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/concat/axis*
T0*
N*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿÊ

Þ
]seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/MatMulMatMul]seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/concatcseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/MatMul/Enter*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿè*
T0
ð
cseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/MatMul/EnterEnterVseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/read*
parallel_iterations * 
_output_shapes
:
Ê
è*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/bw/bw/while/while_context*
T0*
is_constant(
á
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/BiasAddBiasAdd]seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/MatMuldseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/BiasAdd/Enter*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿè*
T0
ê
dseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/BiasAdd/EnterEnterTseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias/read*
parallel_iterations *
_output_shapes	
:è*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/bw/bw/while/while_context*
T0*
is_constant(
Ý
\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/ConstConst=^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity*
dtype0*
_output_shapes
: *
value	B :
ç
fseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/split/split_dimConst=^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity*
dtype0*
_output_shapes
: *
value	B :
­
\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/splitSplitfseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/split/split_dim^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/BiasAdd*
T0*d
_output_shapesR
P:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú*
	num_split
à
\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/add/yConst=^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity*
valueB
 *  ?*
dtype0*
_output_shapes
: 
Ò
Zseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/addAdd^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/split:2\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/add/y*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
ø
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/SigmoidSigmoidZseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/add*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
´
Zseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/mulMul^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/Sigmoid>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_3*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
ü
`seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/Sigmoid_1Sigmoid\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/split*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
ö
[seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/TanhTanh^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/split:1*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
Õ
\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/mul_1Mul`seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/Sigmoid_1[seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/Tanh*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
Ð
\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/add_1AddZseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/mul\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/mul_1*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
þ
`seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/Sigmoid_2Sigmoid^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/split:3*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
ö
]seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/Tanh_1Tanh\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/add_1*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
×
\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/mul_2Mul`seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/Sigmoid_2]seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/Tanh_1*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
©
rseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/shapeConst*
dtype0*
_output_shapes
:*
valueB"ô  è  *d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel

pseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/minConst*
valueB
 *â½*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel*
dtype0*
_output_shapes
: 

pseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/maxConst*
valueB
 *â=*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel*
dtype0*
_output_shapes
: 

zseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/RandomUniformRandomUniformrseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/shape*
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel*
dtype0* 
_output_shapes
:
ôè
â
pseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/subSubpseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/maxpseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/min*
_output_shapes
: *
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel
ö
pseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/mulMulzseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/RandomUniformpseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/sub*
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel* 
_output_shapes
:
ôè
è
lseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniformAddpseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/mulpseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform/min*
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel* 
_output_shapes
:
ôè
æ
Qseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernelVarHandleOp*
dtype0*
_output_shapes
: *
shape:
ôè*b
shared_nameSQseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel
ó
rseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/IsInitialized/VarIsInitializedOpVarIsInitializedOpQseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel*
_output_shapes
: 
 
Xseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/AssignAssignVariableOpQseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernellseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel*
dtype0
ß
eseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Read/ReadVariableOpReadVariableOpQseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel*
dtype0* 
_output_shapes
:
ôè
ý
_seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Read/IdentityIdentityeseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Read/ReadVariableOp* 
_output_shapes
:
ôè*
T0
 
qseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/Initializer/zeros/shape_as_tensorConst*
dtype0*
_output_shapes
:*
valueB:è*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias

gseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/Initializer/zeros/ConstConst*
dtype0*
_output_shapes
: *
valueB
 *    *b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias
Ï
aseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/Initializer/zerosFillqseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/Initializer/zeros/shape_as_tensorgseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/Initializer/zeros/Const*
_output_shapes	
:è*
T0*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias
Û
Oseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/biasVarHandleOp*`
shared_nameQOseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias*
dtype0*
_output_shapes
: *
shape:è
ï
pseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/IsInitialized/VarIsInitializedOpVarIsInitializedOpOseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias*
_output_shapes
: 

Vseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/AssignAssignVariableOpOseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/biasaseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/Initializer/zeros*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias*
dtype0
Ô
cseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/Read/ReadVariableOpReadVariableOpOseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias*
dtype0*
_output_shapes	
:è
ô
]seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/Read/IdentityIdentitycseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/Read/ReadVariableOp*
_output_shapes	
:è*
T0
ã
bseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/concat/axisConst=^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity*
value	B :*
dtype0*
_output_shapes
: 
§
]seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/concatConcatV2\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/mul_2>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_6bseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/concat/axis*
T0*
N*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿô
Þ
]seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/MatMulMatMul]seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/concatcseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/MatMul/Enter*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿè*
T0
ù
cseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/MatMul/EnterEnter_seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Read/Identity*
parallel_iterations * 
_output_shapes
:
ôè*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/bw/bw/while/while_context*
T0*
is_constant(
á
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/BiasAddBiasAdd]seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/MatMuldseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/BiasAdd/Enter*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿè*
T0
ó
dseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/BiasAdd/EnterEnter]seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/Read/Identity*
T0*
is_constant(*
parallel_iterations *
_output_shapes	
:è*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/bw/bw/while/while_context
Ý
\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/ConstConst=^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity*
value	B :*
dtype0*
_output_shapes
: 
ç
fseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/split/split_dimConst=^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity*
value	B :*
dtype0*
_output_shapes
: 
­
\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/splitSplitfseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/split/split_dim^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/BiasAdd*d
_output_shapesR
P:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú:ÿÿÿÿÿÿÿÿÿú*
	num_split*
T0
à
\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/add/yConst=^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity*
valueB
 *  ?*
dtype0*
_output_shapes
: 
Ò
Zseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/addAdd^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/split:2\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/add/y*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
ø
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/SigmoidSigmoidZseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/add*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
´
Zseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/mulMul^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/Sigmoid>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_5*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
ü
`seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/Sigmoid_1Sigmoid\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/split*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
ö
[seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/TanhTanh^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/split:1*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
Õ
\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/mul_1Mul`seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/Sigmoid_1[seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/Tanh*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
Ð
\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/add_1AddZseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/mul\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/mul_1*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
þ
`seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/Sigmoid_2Sigmoid^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/split:3*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
ö
]seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/Tanh_1Tanh\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/add_1*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
×
\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/mul_2Mul`seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/Sigmoid_2]seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/Tanh_1*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
Æ
Pseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/addAdd\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/mul_2\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/mul_2*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
²
:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/SelectSelect@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/GreaterEqual@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Select/EnterPseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/add*
T0*c
_classY
WUloc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/add*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú

@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Select/EnterEnter3seqclassifier/encoder/bidirectional_rnn/bw/bw/zeros*
T0*c
_classY
WUloc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/add*
parallel_iterations *
is_constant(*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/bw/bw/while/while_context
Ê
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Select_1Select@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/GreaterEqual>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_3\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/add_1*
T0*o
_classe
caloc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/add_1*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
Ê
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Select_2Select@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/GreaterEqual>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_4\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/mul_2*
T0*o
_classe
caloc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/mul_2*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
Ê
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Select_3Select@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/GreaterEqual>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_5\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/add_1*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0*o
_classe
caloc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/add_1
Ê
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Select_4Select@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/GreaterEqual>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_6\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/mul_2*
T0*o
_classe
caloc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/mul_2*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú

Wseqclassifier/encoder/bidirectional_rnn/bw/bw/while/TensorArrayWrite/TensorArrayWriteV3TensorArrayWriteV3]seqclassifier/encoder/bidirectional_rnn/bw/bw/while/TensorArrayWrite/TensorArrayWriteV3/Enter>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_1:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Select>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_2*
T0*c
_classY
WUloc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/add*
_output_shapes
: 
¬
]seqclassifier/encoder/bidirectional_rnn/bw/bw/while/TensorArrayWrite/TensorArrayWriteV3/EnterEnter9seqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArray*
T0*c
_classY
WUloc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/add*
parallel_iterations *
is_constant(*Q

frame_nameCAseqclassifier/encoder/bidirectional_rnn/bw/bw/while/while_context*
_output_shapes
:
¼
;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/add_1/yConst=^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity*
dtype0*
_output_shapes
: *
value	B :
Þ
9seqclassifier/encoder/bidirectional_rnn/bw/bw/while/add_1Add>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_1;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/add_1/y*
T0*
_output_shapes
: 
¬
Aseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIterationNextIteration7seqclassifier/encoder/bidirectional_rnn/bw/bw/while/add*
_output_shapes
: *
T0
°
Cseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration_1NextIteration9seqclassifier/encoder/bidirectional_rnn/bw/bw/while/add_1*
T0*
_output_shapes
: 
Î
Cseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration_2NextIterationWseqclassifier/encoder/bidirectional_rnn/bw/bw/while/TensorArrayWrite/TensorArrayWriteV3*
_output_shapes
: *
T0
Å
Cseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration_3NextIteration<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Select_1*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
Å
Cseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration_4NextIteration<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Select_2*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
Å
Cseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration_5NextIteration<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Select_3*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
Å
Cseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration_6NextIteration<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Select_4*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú

8seqclassifier/encoder/bidirectional_rnn/bw/bw/while/ExitExit:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch*
T0*
_output_shapes
: 
¡
:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_1Exit<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_1*
_output_shapes
: *
T0
¡
:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_2Exit<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_2*
_output_shapes
: *
T0
³
:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_3Exit<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_3*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
³
:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_4Exit<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_4*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
³
:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_5Exit<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_5*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú*
T0
³
:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_6Exit<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_6*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿú
Â
Pseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayStack/TensorArraySizeV3TensorArraySizeV39seqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArray:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_2*L
_classB
@>loc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArray*
_output_shapes
: 
Ú
Jseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayStack/range/startConst*
dtype0*
_output_shapes
: *
value	B : *L
_classB
@>loc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArray
Ú
Jseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayStack/range/deltaConst*
value	B :*L
_classB
@>loc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArray*
dtype0*
_output_shapes
: 
ª
Dseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayStack/rangeRangeJseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayStack/range/startPseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayStack/TensorArraySizeV3Jseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayStack/range/delta*#
_output_shapes
:ÿÿÿÿÿÿÿÿÿ*L
_classB
@>loc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArray
ß
Rseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayStack/TensorArrayGatherV3TensorArrayGatherV39seqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayDseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayStack/range:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_2*%
element_shape:ÿÿÿÿÿÿÿÿÿú*L
_classB
@>loc:@seqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArray*
dtype0*5
_output_shapes#
!:ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿú

5seqclassifier/encoder/bidirectional_rnn/bw/bw/Const_4Const*
dtype0*
_output_shapes
:*
valueB:ú
v
4seqclassifier/encoder/bidirectional_rnn/bw/bw/Rank_1Const*
value	B :*
dtype0*
_output_shapes
: 
}
;seqclassifier/encoder/bidirectional_rnn/bw/bw/range_1/startConst*
dtype0*
_output_shapes
: *
value	B :
}
;seqclassifier/encoder/bidirectional_rnn/bw/bw/range_1/deltaConst*
dtype0*
_output_shapes
: *
value	B :

5seqclassifier/encoder/bidirectional_rnn/bw/bw/range_1Range;seqclassifier/encoder/bidirectional_rnn/bw/bw/range_1/start4seqclassifier/encoder/bidirectional_rnn/bw/bw/Rank_1;seqclassifier/encoder/bidirectional_rnn/bw/bw/range_1/delta*
_output_shapes
:

?seqclassifier/encoder/bidirectional_rnn/bw/bw/concat_2/values_0Const*
valueB"       *
dtype0*
_output_shapes
:
}
;seqclassifier/encoder/bidirectional_rnn/bw/bw/concat_2/axisConst*
value	B : *
dtype0*
_output_shapes
: 
¥
6seqclassifier/encoder/bidirectional_rnn/bw/bw/concat_2ConcatV2?seqclassifier/encoder/bidirectional_rnn/bw/bw/concat_2/values_05seqclassifier/encoder/bidirectional_rnn/bw/bw/range_1;seqclassifier/encoder/bidirectional_rnn/bw/bw/concat_2/axis*
N*
_output_shapes
:*
T0

9seqclassifier/encoder/bidirectional_rnn/bw/bw/transpose_1	TransposeRseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayStack/TensorArrayGatherV36seqclassifier/encoder/bidirectional_rnn/bw/bw/concat_2*
T0*5
_output_shapes#
!:ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿú
Ø
%seqclassifier/encoder/ReverseSequenceReverseSequence9seqclassifier/encoder/bidirectional_rnn/bw/bw/transpose_1numWords*
T0*
seq_dim*5
_output_shapes#
!:ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿú*

Tlen0
n
#seqclassifier/encoder/concat_3/axisConst*
valueB :
ÿÿÿÿÿÿÿÿÿ*
dtype0*
_output_shapes
: 
ú
seqclassifier/encoder/concat_3ConcatV29seqclassifier/encoder/bidirectional_rnn/fw/fw/transpose_1%seqclassifier/encoder/ReverseSequence#seqclassifier/encoder/concat_3/axis*
N*5
_output_shapes#
!:ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿô*
T0
n
#seqclassifier/encoder/concat_4/axisConst*
dtype0*
_output_shapes
: *
valueB :
ÿÿÿÿÿÿÿÿÿ

seqclassifier/encoder/concat_4ConcatV2:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_3:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_3#seqclassifier/encoder/concat_4/axis*
T0*
N*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿô
n
#seqclassifier/encoder/concat_5/axisConst*
valueB :
ÿÿÿÿÿÿÿÿÿ*
dtype0*
_output_shapes
: 

seqclassifier/encoder/concat_5ConcatV2:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_4:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_4#seqclassifier/encoder/concat_5/axis*
T0*
N*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿô
n
#seqclassifier/encoder/concat_6/axisConst*
valueB :
ÿÿÿÿÿÿÿÿÿ*
dtype0*
_output_shapes
: 

seqclassifier/encoder/concat_6ConcatV2:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_5:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_5#seqclassifier/encoder/concat_6/axis*
T0*
N*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿô
n
#seqclassifier/encoder/concat_7/axisConst*
valueB :
ÿÿÿÿÿÿÿÿÿ*
dtype0*
_output_shapes
: 

seqclassifier/encoder/concat_7ConcatV2:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_6:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_6#seqclassifier/encoder/concat_7/axis*
N*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿô*
T0
f
$seqclassifier/Mean/reduction_indicesConst*
value	B :*
dtype0*
_output_shapes
: 

seqclassifier/MeanMeanseqclassifier/encoder/concat_3$seqclassifier/Mean/reduction_indices*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿô
d
seqclassifier/concat/axisConst*
valueB :
ÿÿÿÿÿÿÿÿÿ*
dtype0*
_output_shapes
: 

seqclassifier/concatConcatV2seqclassifier/MeanglobalFeaturesseqclassifier/concat/axis*
T0*
N*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿî
»
;seqclassifier/dense/kernel/Initializer/random_uniform/shapeConst*
valueB"n     *-
_class#
!loc:@seqclassifier/dense/kernel*
dtype0*
_output_shapes
:
­
9seqclassifier/dense/kernel/Initializer/random_uniform/minConst*
valueB
 *Wø½*-
_class#
!loc:@seqclassifier/dense/kernel*
dtype0*
_output_shapes
: 
­
9seqclassifier/dense/kernel/Initializer/random_uniform/maxConst*
valueB
 *Wø=*-
_class#
!loc:@seqclassifier/dense/kernel*
dtype0*
_output_shapes
: 
ø
Cseqclassifier/dense/kernel/Initializer/random_uniform/RandomUniformRandomUniform;seqclassifier/dense/kernel/Initializer/random_uniform/shape*
dtype0* 
_output_shapes
:
î*
T0*-
_class#
!loc:@seqclassifier/dense/kernel

9seqclassifier/dense/kernel/Initializer/random_uniform/subSub9seqclassifier/dense/kernel/Initializer/random_uniform/max9seqclassifier/dense/kernel/Initializer/random_uniform/min*
_output_shapes
: *
T0*-
_class#
!loc:@seqclassifier/dense/kernel

9seqclassifier/dense/kernel/Initializer/random_uniform/mulMulCseqclassifier/dense/kernel/Initializer/random_uniform/RandomUniform9seqclassifier/dense/kernel/Initializer/random_uniform/sub*
T0*-
_class#
!loc:@seqclassifier/dense/kernel* 
_output_shapes
:
î

5seqclassifier/dense/kernel/Initializer/random_uniformAdd9seqclassifier/dense/kernel/Initializer/random_uniform/mul9seqclassifier/dense/kernel/Initializer/random_uniform/min* 
_output_shapes
:
î*
T0*-
_class#
!loc:@seqclassifier/dense/kernel

seqclassifier/dense/kernel
VariableV2*-
_class#
!loc:@seqclassifier/dense/kernel*
dtype0* 
_output_shapes
:
î*
shape:
î
Ø
!seqclassifier/dense/kernel/AssignAssignseqclassifier/dense/kernel5seqclassifier/dense/kernel/Initializer/random_uniform*
T0*-
_class#
!loc:@seqclassifier/dense/kernel* 
_output_shapes
:
î
¡
seqclassifier/dense/kernel/readIdentityseqclassifier/dense/kernel* 
_output_shapes
:
î*
T0*-
_class#
!loc:@seqclassifier/dense/kernel
¦
*seqclassifier/dense/bias/Initializer/zerosConst*
valueB*    *+
_class!
loc:@seqclassifier/dense/bias*
dtype0*
_output_shapes	
:

seqclassifier/dense/bias
VariableV2*
dtype0*
_output_shapes	
:*
shape:*+
_class!
loc:@seqclassifier/dense/bias
Â
seqclassifier/dense/bias/AssignAssignseqclassifier/dense/bias*seqclassifier/dense/bias/Initializer/zeros*
T0*+
_class!
loc:@seqclassifier/dense/bias*
_output_shapes	
:

seqclassifier/dense/bias/readIdentityseqclassifier/dense/bias*
T0*+
_class!
loc:@seqclassifier/dense/bias*
_output_shapes	
:

seqclassifier/dense/MatMulMatMulseqclassifier/concatseqclassifier/dense/kernel/read*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿ*
T0

seqclassifier/dense/BiasAddBiasAddseqclassifier/dense/MatMulseqclassifier/dense/bias/read*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿ*
T0
p
seqclassifier/dense/ReluReluseqclassifier/dense/BiasAdd*
T0*(
_output_shapes
:ÿÿÿÿÿÿÿÿÿ
Ï
Eseqclassifier/generator/dense/kernel/Initializer/random_uniform/shapeConst*
dtype0*
_output_shapes
:*
valueB"      *7
_class-
+)loc:@seqclassifier/generator/dense/kernel
Á
Cseqclassifier/generator/dense/kernel/Initializer/random_uniform/minConst*
valueB
 *KQ¾*7
_class-
+)loc:@seqclassifier/generator/dense/kernel*
dtype0*
_output_shapes
: 
Á
Cseqclassifier/generator/dense/kernel/Initializer/random_uniform/maxConst*
valueB
 *KQ>*7
_class-
+)loc:@seqclassifier/generator/dense/kernel*
dtype0*
_output_shapes
: 

Mseqclassifier/generator/dense/kernel/Initializer/random_uniform/RandomUniformRandomUniformEseqclassifier/generator/dense/kernel/Initializer/random_uniform/shape*
dtype0*
_output_shapes
:	*
T0*7
_class-
+)loc:@seqclassifier/generator/dense/kernel
®
Cseqclassifier/generator/dense/kernel/Initializer/random_uniform/subSubCseqclassifier/generator/dense/kernel/Initializer/random_uniform/maxCseqclassifier/generator/dense/kernel/Initializer/random_uniform/min*
_output_shapes
: *
T0*7
_class-
+)loc:@seqclassifier/generator/dense/kernel
Á
Cseqclassifier/generator/dense/kernel/Initializer/random_uniform/mulMulMseqclassifier/generator/dense/kernel/Initializer/random_uniform/RandomUniformCseqclassifier/generator/dense/kernel/Initializer/random_uniform/sub*
_output_shapes
:	*
T0*7
_class-
+)loc:@seqclassifier/generator/dense/kernel
³
?seqclassifier/generator/dense/kernel/Initializer/random_uniformAddCseqclassifier/generator/dense/kernel/Initializer/random_uniform/mulCseqclassifier/generator/dense/kernel/Initializer/random_uniform/min*
T0*7
_class-
+)loc:@seqclassifier/generator/dense/kernel*
_output_shapes
:	
¯
$seqclassifier/generator/dense/kernel
VariableV2*7
_class-
+)loc:@seqclassifier/generator/dense/kernel*
dtype0*
_output_shapes
:	*
shape:	
ÿ
+seqclassifier/generator/dense/kernel/AssignAssign$seqclassifier/generator/dense/kernel?seqclassifier/generator/dense/kernel/Initializer/random_uniform*
_output_shapes
:	*
T0*7
_class-
+)loc:@seqclassifier/generator/dense/kernel
¾
)seqclassifier/generator/dense/kernel/readIdentity$seqclassifier/generator/dense/kernel*
_output_shapes
:	*
T0*7
_class-
+)loc:@seqclassifier/generator/dense/kernel
¸
4seqclassifier/generator/dense/bias/Initializer/zerosConst*
valueB*    *5
_class+
)'loc:@seqclassifier/generator/dense/bias*
dtype0*
_output_shapes
:
¡
"seqclassifier/generator/dense/bias
VariableV2*
dtype0*
_output_shapes
:*
shape:*5
_class+
)'loc:@seqclassifier/generator/dense/bias
é
)seqclassifier/generator/dense/bias/AssignAssign"seqclassifier/generator/dense/bias4seqclassifier/generator/dense/bias/Initializer/zeros*
T0*5
_class+
)'loc:@seqclassifier/generator/dense/bias*
_output_shapes
:
³
'seqclassifier/generator/dense/bias/readIdentity"seqclassifier/generator/dense/bias*
_output_shapes
:*
T0*5
_class+
)'loc:@seqclassifier/generator/dense/bias
¥
$seqclassifier/generator/dense/MatMulMatMulseqclassifier/dense/Relu)seqclassifier/generator/dense/kernel/read*
T0*'
_output_shapes
:ÿÿÿÿÿÿÿÿÿ
±
%seqclassifier/generator/dense/BiasAddBiasAdd$seqclassifier/generator/dense/MatMul'seqclassifier/generator/dense/bias/read*
T0*'
_output_shapes
:ÿÿÿÿÿÿÿÿÿ
y
seqclassifier/SigmoidSigmoid%seqclassifier/generator/dense/BiasAdd*'
_output_shapes
:ÿÿÿÿÿÿÿÿÿ*
T0
e
seqclassifier/RoundRoundseqclassifier/Sigmoid*'
_output_shapes
:ÿÿÿÿÿÿÿÿÿ*
T0

initNoOp

init_all_tablesNoOp

init_1NoOp
4

group_depsNoOp^init^init_1^init_all_tables
Y
save/filename/inputConst*
dtype0*
_output_shapes
: *
valueB Bmodel
n
save/filenamePlaceholderWithDefaultsave/filename/input*
dtype0*
_output_shapes
: *
shape: 
e

save/ConstPlaceholderWithDefaultsave/filename*
dtype0*
_output_shapes
: *
shape: 

save/StringJoin/inputs_1Const*
dtype0*
_output_shapes
: *<
value3B1 B+_temp_5a2fbe40467c4f23a2b6de8ba79195f1/part
d
save/StringJoin
StringJoin
save/Constsave/StringJoin/inputs_1*
N*
_output_shapes
: 
Q
save/num_shardsConst*
dtype0*
_output_shapes
: *
value	B :
k
save/ShardedFilename/shardConst"/device:CPU:0*
dtype0*
_output_shapes
: *
value	B : 

save/ShardedFilenameShardedFilenamesave/StringJoinsave/ShardedFilename/shardsave/num_shards"/device:CPU:0*
_output_shapes
: 
®
save/SaveV2/tensor_namesConst"/device:CPU:0*Ò
valueÈBÅBglobal_stepBseqclassifier/dense/biasBseqclassifier/dense/kernelBseqclassifier/encoder/VariableBOseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/biasBQseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernelBOseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/biasBQseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernelBOseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/biasBQseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernelBOseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/biasBQseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernelB"seqclassifier/generator/dense/biasB$seqclassifier/generator/dense/kernel*
dtype0*
_output_shapes
:

save/SaveV2/shape_and_slicesConst"/device:CPU:0*/
value&B$B B B B B B B B B B B B B B *
dtype0*
_output_shapes
:

save/SaveV2SaveV2save/ShardedFilenamesave/SaveV2/tensor_namessave/SaveV2/shape_and_slicesglobal_stepseqclassifier/dense/biasseqclassifier/dense/kernelseqclassifier/encoder/VariableOseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/biasQseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernelcseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/Read/ReadVariableOpeseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Read/ReadVariableOpOseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/biasQseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernelcseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/Read/ReadVariableOpeseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Read/ReadVariableOp"seqclassifier/generator/dense/bias$seqclassifier/generator/dense/kernel"/device:CPU:0*
dtypes
2	
 
save/control_dependencyIdentitysave/ShardedFilename^save/SaveV2"/device:CPU:0*
_output_shapes
: *
T0*'
_class
loc:@save/ShardedFilename
 
+save/MergeV2Checkpoints/checkpoint_prefixesPacksave/ShardedFilename^save/control_dependency"/device:CPU:0*
N*
_output_shapes
:*
T0
u
save/MergeV2CheckpointsMergeV2Checkpoints+save/MergeV2Checkpoints/checkpoint_prefixes
save/Const"/device:CPU:0

save/IdentityIdentity
save/Const^save/MergeV2Checkpoints^save/control_dependency"/device:CPU:0*
_output_shapes
: *
T0
±
save/RestoreV2/tensor_namesConst"/device:CPU:0*
dtype0*
_output_shapes
:*Ò
valueÈBÅBglobal_stepBseqclassifier/dense/biasBseqclassifier/dense/kernelBseqclassifier/encoder/VariableBOseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/biasBQseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernelBOseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/biasBQseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernelBOseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/biasBQseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernelBOseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/biasBQseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernelB"seqclassifier/generator/dense/biasB$seqclassifier/generator/dense/kernel

save/RestoreV2/shape_and_slicesConst"/device:CPU:0*/
value&B$B B B B B B B B B B B B B B *
dtype0*
_output_shapes
:
à
save/RestoreV2	RestoreV2
save/Constsave/RestoreV2/tensor_namessave/RestoreV2/shape_and_slices"/device:CPU:0*L
_output_shapes:
8::::::::::::::*
dtypes
2	
s
save/AssignAssignglobal_stepsave/RestoreV2*
_output_shapes
: *
T0	*
_class
loc:@global_step

save/Assign_1Assignseqclassifier/dense/biassave/RestoreV2:1*
T0*+
_class!
loc:@seqclassifier/dense/bias*
_output_shapes	
:

save/Assign_2Assignseqclassifier/dense/kernelsave/RestoreV2:2*
T0*-
_class#
!loc:@seqclassifier/dense/kernel* 
_output_shapes
:
î
¡
save/Assign_3Assignseqclassifier/encoder/Variablesave/RestoreV2:3*
T0*1
_class'
%#loc:@seqclassifier/encoder/Variable*
_output_shapes
:

save/Assign_4AssignOseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/biassave/RestoreV2:4*
T0*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias*
_output_shapes	
:è

save/Assign_5AssignQseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernelsave/RestoreV2:5* 
_output_shapes
:
Ê
è*
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel
P
save/Identity_1Identitysave/RestoreV2:6*
T0*
_output_shapes
:

save/AssignVariableOpAssignVariableOpOseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/biassave/Identity_1*
dtype0
P
save/Identity_2Identitysave/RestoreV2:7*
_output_shapes
:*
T0

save/AssignVariableOp_1AssignVariableOpQseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernelsave/Identity_2*
dtype0

save/Assign_6AssignOseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/biassave/RestoreV2:8*
_output_shapes	
:è*
T0*b
_classX
VTloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias

save/Assign_7AssignQseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernelsave/RestoreV2:9* 
_output_shapes
:
Ê
è*
T0*d
_classZ
XVloc:@seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel
Q
save/Identity_3Identitysave/RestoreV2:10*
_output_shapes
:*
T0

save/AssignVariableOp_2AssignVariableOpOseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/biassave/Identity_3*
dtype0
Q
save/Identity_4Identitysave/RestoreV2:11*
T0*
_output_shapes
:

save/AssignVariableOp_3AssignVariableOpQseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernelsave/Identity_4*
dtype0
ª
save/Assign_8Assign"seqclassifier/generator/dense/biassave/RestoreV2:12*
_output_shapes
:*
T0*5
_class+
)'loc:@seqclassifier/generator/dense/bias
³
save/Assign_9Assign$seqclassifier/generator/dense/kernelsave/RestoreV2:13*
T0*7
_class-
+)loc:@seqclassifier/generator/dense/kernel*
_output_shapes
:	

save/restore_shardNoOp^save/Assign^save/AssignVariableOp^save/AssignVariableOp_1^save/AssignVariableOp_2^save/AssignVariableOp_3^save/Assign_1^save/Assign_2^save/Assign_3^save/Assign_4^save/Assign_5^save/Assign_6^save/Assign_7^save/Assign_8^save/Assign_9
-
save/restore_allNoOp^save/restore_shard


$Dataset_flat_map_read_one_file_18267
arg0
tfrecorddataset2DWrapper for passing nested structures to and from tf.data functions.9
compression_typeConst*
valueB B *
dtype07
buffer_sizeConst*
dtype0	*
valueB		 RY
TFRecordDatasetTFRecordDatasetarg0compression_type:output:0buffer_size:output:0"+
tfrecorddatasetTFRecordDataset:handle:0"<
save/Const:0save/Identity:0save/restore_all (5 @F8"Æ
trainable_variables®«

 seqclassifier/encoder/Variable:0%seqclassifier/encoder/Variable/Assign%seqclassifier/encoder/Variable/read:02&seqclassifier/encoder/random_uniform:08
û
Sseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel:0Xseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/AssignXseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/read:02nseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform:08
ê
Qseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias:0Vseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias/AssignVseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias/read:02cseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias/Initializer/zeros:08

Sseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel:0Xseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Assignaseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Read/Identity:0(2nseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform:08
õ
Qseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias:0Vseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/Assign_seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/Read/Identity:0(2cseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/Initializer/zeros:08
û
Sseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel:0Xseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/AssignXseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/read:02nseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform:08
ê
Qseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias:0Vseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias/AssignVseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias/read:02cseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias/Initializer/zeros:08

Sseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel:0Xseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Assignaseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Read/Identity:0(2nseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform:08
õ
Qseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias:0Vseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/Assign_seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/Read/Identity:0(2cseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/Initializer/zeros:08

seqclassifier/dense/kernel:0!seqclassifier/dense/kernel/Assign!seqclassifier/dense/kernel/read:027seqclassifier/dense/kernel/Initializer/random_uniform:08

seqclassifier/dense/bias:0seqclassifier/dense/bias/Assignseqclassifier/dense/bias/read:02,seqclassifier/dense/bias/Initializer/zeros:08
Ç
&seqclassifier/generator/dense/kernel:0+seqclassifier/generator/dense/kernel/Assign+seqclassifier/generator/dense/kernel/read:02Aseqclassifier/generator/dense/kernel/Initializer/random_uniform:08
¶
$seqclassifier/generator/dense/bias:0)seqclassifier/generator/dense/bias/Assign)seqclassifier/generator/dense/bias/read:026seqclassifier/generator/dense/bias/Initializer/zeros:08"k
global_step\Z
X
global_step:0global_step/Assignglobal_step/read:02global_step/Initializer/zeros:0"Õ
while_contextöÔòÔ
¶j
Aseqclassifier/encoder/bidirectional_rnn/fw/fw/while/while_context *>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/LoopCond:02;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge:0:>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity:0B:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit:0B<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_1:0B<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_2:0B<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_3:0B<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_4:0B<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_5:0B<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_6:0Ja
;seqclassifier/encoder/bidirectional_rnn/fw/fw/CheckSeqLen:0
7seqclassifier/encoder/bidirectional_rnn/fw/fw/Minimum:0
;seqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArray:0
jseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/TensorArrayScatter/TensorArrayScatterV3:0
=seqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArray_1:0
?seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_1:0
;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter:0
=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_1:0
=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_2:0
=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_3:0
=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_4:0
=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_5:0
=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_6:0
:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit:0
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_1:0
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_2:0
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_3:0
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_4:0
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_5:0
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Exit_6:0
Hseqclassifier/encoder/bidirectional_rnn/fw/fw/while/GreaterEqual/Enter:0
Bseqclassifier/encoder/bidirectional_rnn/fw/fw/while/GreaterEqual:0
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity:0
@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_1:0
@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_2:0
@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_3:0
@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_4:0
@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_5:0
@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Identity_6:0
@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Less/Enter:0
:seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Less:0
Bseqclassifier/encoder/bidirectional_rnn/fw/fw/while/Less_1/Enter:0
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Less_1:0
@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/LogicalAnd:0
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/LoopCond:0
;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge:0
;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge:1
=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_1:0
=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_1:1
=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_2:0
=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_2:1
=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_3:0
=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_3:1
=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_4:0
=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_4:1
=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_5:0
=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_5:1
=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_6:0
=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Merge_6:1
Cseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration:0
Eseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration_1:0
Eseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration_2:0
Eseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration_3:0
Eseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration_4:0
Eseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration_5:0
Eseqclassifier/encoder/bidirectional_rnn/fw/fw/while/NextIteration_6:0
Bseqclassifier/encoder/bidirectional_rnn/fw/fw/while/Select/Enter:0
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Select:0
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Select_1:0
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Select_2:0
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Select_3:0
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Select_4:0
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch:0
<seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch:1
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_1:0
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_1:1
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_2:0
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_2:1
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_3:0
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_3:1
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_4:0
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_4:1
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_5:0
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_5:1
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_6:0
>seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Switch_6:1
Mseqclassifier/encoder/bidirectional_rnn/fw/fw/while/TensorArrayReadV3/Enter:0
Oseqclassifier/encoder/bidirectional_rnn/fw/fw/while/TensorArrayReadV3/Enter_1:0
Gseqclassifier/encoder/bidirectional_rnn/fw/fw/while/TensorArrayReadV3:0
_seqclassifier/encoder/bidirectional_rnn/fw/fw/while/TensorArrayWrite/TensorArrayWriteV3/Enter:0
Yseqclassifier/encoder/bidirectional_rnn/fw/fw/while/TensorArrayWrite/TensorArrayWriteV3:0
;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/add/y:0
9seqclassifier/encoder/bidirectional_rnn/fw/fw/while/add:0
=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/add_1/y:0
;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/add_1:0
fseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/BiasAdd/Enter:0
`seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/BiasAdd:0
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/Const:0
eseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/MatMul/Enter:0
_seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/MatMul:0
`seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/Sigmoid:0
bseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/Sigmoid_1:0
bseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/Sigmoid_2:0
]seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/Tanh:0
_seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/Tanh_1:0
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/add/y:0
\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/add:0
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/add_1:0
dseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/concat/axis:0
_seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/concat:0
\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/mul:0
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/mul_1:0
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/mul_2:0
hseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/split/split_dim:0
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/split:0
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/split:1
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/split:2
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/split:3
Rseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/add:0
fseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/BiasAdd/Enter:0
`seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/BiasAdd:0
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/Const:0
eseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/MatMul/Enter:0
_seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/MatMul:0
`seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/Sigmoid:0
bseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/Sigmoid_1:0
bseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/Sigmoid_2:0
]seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/Tanh:0
_seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/Tanh_1:0
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/add/y:0
\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/add:0
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/add_1:0
dseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/concat/axis:0
_seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/concat:0
\seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/mul:0
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/mul_1:0
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/mul_2:0
hseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/split/split_dim:0
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/split:0
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/split:1
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/split:2
^seqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/split:3
5seqclassifier/encoder/bidirectional_rnn/fw/fw/zeros:0
Vseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias/read:0
Xseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/read:0
_seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/Read/Identity:0
aseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Read/Identity:0{
5seqclassifier/encoder/bidirectional_rnn/fw/fw/zeros:0Bseqclassifier/encoder/bidirectional_rnn/fw/fw/while/Select/Enter:0Á
Xseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/read:0eseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/MatMul/Enter:0
;seqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArray:0_seqclassifier/encoder/bidirectional_rnn/fw/fw/while/TensorArrayWrite/TensorArrayWriteV3/Enter:0}
7seqclassifier/encoder/bidirectional_rnn/fw/fw/Minimum:0Bseqclassifier/encoder/bidirectional_rnn/fw/fw/while/Less_1/Enter:0É
_seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/Read/Identity:0fseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/BiasAdd/Enter:0
=seqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArray_1:0Mseqclassifier/encoder/bidirectional_rnn/fw/fw/while/TensorArrayReadV3/Enter:0
;seqclassifier/encoder/bidirectional_rnn/fw/fw/CheckSeqLen:0Hseqclassifier/encoder/bidirectional_rnn/fw/fw/while/GreaterEqual/Enter:0À
Vseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias/read:0fseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_0/lstm_cell/BiasAdd/Enter:0Ê
aseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Read/Identity:0eseqclassifier/encoder/bidirectional_rnn/fw/fw/while/fw/multi_rnn_cell/cell_1/lstm_cell/MatMul/Enter:0
?seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_1:0@seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Less/Enter:0½
jseqclassifier/encoder/bidirectional_rnn/fw/fw/TensorArrayUnstack/TensorArrayScatter/TensorArrayScatterV3:0Oseqclassifier/encoder/bidirectional_rnn/fw/fw/while/TensorArrayReadV3/Enter_1:0R;seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter:0R=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_1:0R=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_2:0R=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_3:0R=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_4:0R=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_5:0R=seqclassifier/encoder/bidirectional_rnn/fw/fw/while/Enter_6:0Z?seqclassifier/encoder/bidirectional_rnn/fw/fw/strided_slice_1:0
¶j
Aseqclassifier/encoder/bidirectional_rnn/bw/bw/while/while_context *>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/LoopCond:02;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge:0:>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity:0B:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit:0B<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_1:0B<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_2:0B<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_3:0B<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_4:0B<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_5:0B<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_6:0Ja
;seqclassifier/encoder/bidirectional_rnn/bw/bw/CheckSeqLen:0
7seqclassifier/encoder/bidirectional_rnn/bw/bw/Minimum:0
;seqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArray:0
jseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/TensorArrayScatter/TensorArrayScatterV3:0
=seqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArray_1:0
?seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_1:0
;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter:0
=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_1:0
=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_2:0
=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_3:0
=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_4:0
=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_5:0
=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_6:0
:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit:0
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_1:0
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_2:0
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_3:0
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_4:0
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_5:0
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Exit_6:0
Hseqclassifier/encoder/bidirectional_rnn/bw/bw/while/GreaterEqual/Enter:0
Bseqclassifier/encoder/bidirectional_rnn/bw/bw/while/GreaterEqual:0
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity:0
@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_1:0
@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_2:0
@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_3:0
@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_4:0
@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_5:0
@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Identity_6:0
@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Less/Enter:0
:seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Less:0
Bseqclassifier/encoder/bidirectional_rnn/bw/bw/while/Less_1/Enter:0
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Less_1:0
@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/LogicalAnd:0
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/LoopCond:0
;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge:0
;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge:1
=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_1:0
=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_1:1
=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_2:0
=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_2:1
=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_3:0
=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_3:1
=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_4:0
=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_4:1
=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_5:0
=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_5:1
=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_6:0
=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Merge_6:1
Cseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration:0
Eseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration_1:0
Eseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration_2:0
Eseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration_3:0
Eseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration_4:0
Eseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration_5:0
Eseqclassifier/encoder/bidirectional_rnn/bw/bw/while/NextIteration_6:0
Bseqclassifier/encoder/bidirectional_rnn/bw/bw/while/Select/Enter:0
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Select:0
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Select_1:0
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Select_2:0
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Select_3:0
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Select_4:0
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch:0
<seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch:1
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_1:0
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_1:1
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_2:0
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_2:1
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_3:0
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_3:1
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_4:0
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_4:1
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_5:0
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_5:1
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_6:0
>seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Switch_6:1
Mseqclassifier/encoder/bidirectional_rnn/bw/bw/while/TensorArrayReadV3/Enter:0
Oseqclassifier/encoder/bidirectional_rnn/bw/bw/while/TensorArrayReadV3/Enter_1:0
Gseqclassifier/encoder/bidirectional_rnn/bw/bw/while/TensorArrayReadV3:0
_seqclassifier/encoder/bidirectional_rnn/bw/bw/while/TensorArrayWrite/TensorArrayWriteV3/Enter:0
Yseqclassifier/encoder/bidirectional_rnn/bw/bw/while/TensorArrayWrite/TensorArrayWriteV3:0
;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/add/y:0
9seqclassifier/encoder/bidirectional_rnn/bw/bw/while/add:0
=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/add_1/y:0
;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/add_1:0
fseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/BiasAdd/Enter:0
`seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/BiasAdd:0
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/Const:0
eseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/MatMul/Enter:0
_seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/MatMul:0
`seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/Sigmoid:0
bseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/Sigmoid_1:0
bseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/Sigmoid_2:0
]seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/Tanh:0
_seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/Tanh_1:0
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/add/y:0
\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/add:0
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/add_1:0
dseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/concat/axis:0
_seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/concat:0
\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/mul:0
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/mul_1:0
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/mul_2:0
hseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/split/split_dim:0
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/split:0
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/split:1
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/split:2
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/split:3
Rseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/add:0
fseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/BiasAdd/Enter:0
`seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/BiasAdd:0
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/Const:0
eseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/MatMul/Enter:0
_seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/MatMul:0
`seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/Sigmoid:0
bseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/Sigmoid_1:0
bseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/Sigmoid_2:0
]seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/Tanh:0
_seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/Tanh_1:0
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/add/y:0
\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/add:0
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/add_1:0
dseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/concat/axis:0
_seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/concat:0
\seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/mul:0
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/mul_1:0
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/mul_2:0
hseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/split/split_dim:0
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/split:0
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/split:1
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/split:2
^seqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/split:3
5seqclassifier/encoder/bidirectional_rnn/bw/bw/zeros:0
Vseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias/read:0
Xseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/read:0
_seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/Read/Identity:0
aseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Read/Identity:0
?seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_1:0@seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Less/Enter:0½
jseqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArrayUnstack/TensorArrayScatter/TensorArrayScatterV3:0Oseqclassifier/encoder/bidirectional_rnn/bw/bw/while/TensorArrayReadV3/Enter_1:0{
5seqclassifier/encoder/bidirectional_rnn/bw/bw/zeros:0Bseqclassifier/encoder/bidirectional_rnn/bw/bw/while/Select/Enter:0Ê
aseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Read/Identity:0eseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/MatMul/Enter:0À
Vseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias/read:0fseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/BiasAdd/Enter:0
;seqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArray:0_seqclassifier/encoder/bidirectional_rnn/bw/bw/while/TensorArrayWrite/TensorArrayWriteV3/Enter:0}
7seqclassifier/encoder/bidirectional_rnn/bw/bw/Minimum:0Bseqclassifier/encoder/bidirectional_rnn/bw/bw/while/Less_1/Enter:0Á
Xseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/read:0eseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_0/lstm_cell/MatMul/Enter:0
=seqclassifier/encoder/bidirectional_rnn/bw/bw/TensorArray_1:0Mseqclassifier/encoder/bidirectional_rnn/bw/bw/while/TensorArrayReadV3/Enter:0
;seqclassifier/encoder/bidirectional_rnn/bw/bw/CheckSeqLen:0Hseqclassifier/encoder/bidirectional_rnn/bw/bw/while/GreaterEqual/Enter:0É
_seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/Read/Identity:0fseqclassifier/encoder/bidirectional_rnn/bw/bw/while/bw/multi_rnn_cell/cell_1/lstm_cell/BiasAdd/Enter:0R;seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter:0R=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_1:0R=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_2:0R=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_3:0R=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_4:0R=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_5:0R=seqclassifier/encoder/bidirectional_rnn/bw/bw/while/Enter_6:0Z?seqclassifier/encoder/bidirectional_rnn/bw/bw/strided_slice_1:0"
	variables
X
global_step:0global_step/Assignglobal_step/read:02global_step/Initializer/zeros:0

 seqclassifier/encoder/Variable:0%seqclassifier/encoder/Variable/Assign%seqclassifier/encoder/Variable/read:02&seqclassifier/encoder/random_uniform:08
û
Sseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel:0Xseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/AssignXseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/read:02nseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform:08
ê
Qseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias:0Vseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias/AssignVseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias/read:02cseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_0/lstm_cell/bias/Initializer/zeros:08

Sseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel:0Xseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Assignaseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Read/Identity:0(2nseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform:08
õ
Qseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias:0Vseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/Assign_seqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/Read/Identity:0(2cseqclassifier/encoder/bidirectional_rnn/fw/multi_rnn_cell/cell_1/lstm_cell/bias/Initializer/zeros:08
û
Sseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel:0Xseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/AssignXseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/read:02nseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/kernel/Initializer/random_uniform:08
ê
Qseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias:0Vseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias/AssignVseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias/read:02cseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_0/lstm_cell/bias/Initializer/zeros:08

Sseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel:0Xseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Assignaseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Read/Identity:0(2nseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/kernel/Initializer/random_uniform:08
õ
Qseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias:0Vseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/Assign_seqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/Read/Identity:0(2cseqclassifier/encoder/bidirectional_rnn/bw/multi_rnn_cell/cell_1/lstm_cell/bias/Initializer/zeros:08

seqclassifier/dense/kernel:0!seqclassifier/dense/kernel/Assign!seqclassifier/dense/kernel/read:027seqclassifier/dense/kernel/Initializer/random_uniform:08

seqclassifier/dense/bias:0seqclassifier/dense/bias/Assignseqclassifier/dense/bias/read:02,seqclassifier/dense/bias/Initializer/zeros:08
Ç
&seqclassifier/generator/dense/kernel:0+seqclassifier/generator/dense/kernel/Assign+seqclassifier/generator/dense/kernel/read:02Aseqclassifier/generator/dense/kernel/Initializer/random_uniform:08
¶
$seqclassifier/generator/dense/bias:0)seqclassifier/generator/dense/bias/Assign)seqclassifier/generator/dense/bias/read:026seqclassifier/generator/dense/bias/Initializer/zeros:08"%
saved_model_main_op


group_deps*
serving_default
)
numWords

numWords:0ÿÿÿÿÿÿÿÿÿ
:
globalFeatures(
globalFeatures:0ÿÿÿÿÿÿÿÿÿú
C
wordFeatures3
wordFeatures:0ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÐ
?
lmLayers3

lmLayers:0#ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ6
labels,
seqclassifier/Round:0ÿÿÿÿÿÿÿÿÿ?
probabilities.
seqclassifier/Sigmoid:0ÿÿÿÿÿÿÿÿÿtensorflow/serving/predict