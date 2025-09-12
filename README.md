# Optimal block packing

In this problem, we are trying to find an optimal way to pack n pseudo randomly generated blocks into a container.
We are trying to minimize container height, while still being able to pack all of the blocks.
This means we need to find the best order in which we are going to be placing blocks into the container.

Program consists of two parts:
1) Block placing algorithm
2) Finding optimal order of placing blocks

## Block placing algorithm:
### Initial idea:
We are trying to make a block placing algorithm that:
1) Doesn’t allow illegal block states
2) Is optimal for a certain order of blocks
3) Is reasonable fast

In order for the algorithm to be optimal it has to always place the next block in the lowest possible space.

The container is absolutely continuous.
This means that we need to save all possible points where we can place a block into, in some structure that we can easily iterate through.
We will call these points candidate points.

We want to place as many blocks as possible on each level.
With this in mind, it’s trivial to deduce that placing blocks right next to each other, and next to container walls, is better than placing blocks randomly onto said level, since it leaves more space for other blocks to fit into.

It follows that the optimal place for the first block is (0,0,0).
The next block is either next to the first block (on either side, if it can fit), or in (0, first block height, 0), if it cannot fit.
--image--

We can define our block placing algorithm with:
0) A structure that holds all our candidate points
1) A part of the algorithm that iterates through said structure and finds the best possible point to place the next block into
2) A part of the algorithm that adds new candidate points to the structure for future blocks to be added into
3) A part of the algorithm that removes all illegal points from the structure

In order to understand the need for all of these parts, we need to remember our first condition for a good block placing algorithm:
"Doesn’t allow illegal block states"

Illegal block states are:
1) Outside blocks - Blocks outside the container
2) Floating blocks - Blocks that can, but don’t fall down to the lowest possible space underneath them
3) Overlapping blocks - Blocks that when placed overlap with already placed blocks
4) Ghost blocks - Blocks that pass through another block while falling into a space

### Outside blocks:
For each new block, before placing it into a point, we need to check if that block will fit inside the container.
```
if p.x + block.width <= container_width and p.z + block.depth <= container_depth:
```

### Floating blocks:
--image--
As we can see it’s not enough to simply add points A, B and C as new candidate points.
Let’s focus on point A:
We don’t want to add A as a candidate point.
Instead we want (A.x , p_best_A.y, A.z) to be the next candidate point, where p_best.y value is the height of the block directly underneath point A.
We can find this point p_best by going through all other points that have smaller x, y and z than our block, and finding the closest one to it:

For our condition on which candidate points are possible we use:
```
if p.x <= A.x and p.y <= A.y and p.z <= A.z:
```

And to find the closest one (in a top down 2D view):
p_best_A = p_i | max((p_i.x + 1) * (p_i.z + 1)) for every i

We increase each coordinate by 1 to avoid multiplication with a 0 value.

Finding the actual candidate point for point B is analogous.

Even though it may seem like C will always be a candidate point we can see that is not the case:
--image--

This means we need to repeat a similar process for finding the candidate point for point C.
This candidate point will be (p_best_C.x , C.y, p_best_C.z)
And p_best_C we are finding in a subset of all candidate points that meet the condition:
```
if p.x <= A.x and p.y <= A.y and p.z <= A.z:
```
and out of all those points we select the highest one:
p_best_C = p_i | max(p_i.y) for every i

This is the candidate point adding part of the algorithm.

### Overlapping blocks:
To solve this problem we need to expand on our candidate points structure.

When placing a block into a candidate point, we need to be able to check if that block will overlap with any other block:
--image--

For each candidate point p we need to check if the new block will intersect any other block.
This means we need to save some information about block size as well as candidate points.

We will have 2 arrays: one for candidate points and another for control points (to check for overlaps), and then with each new block, besides updating candidate points, we need to add that block’s overlap control point to the control points array.
--image---- image --

The overlap control point besides (x,y,z) holds block’s width and block’s depth.
This isn’t enough to recreate the whole block, but we don’t have to. We only need to check if the block will intersect with any of the rectangles above it in the top down 2D view:
--image--

What if an already placed block A would be above block B, if we place it into candidate point p, but they wouldn’t intersect?
--image--
We mark candidate point p as illegal for block B, since that would be a ghost block.

However, it’s not enough to just find the lowest candidate point that doesn’t allow for overlapping blocks, because there might be a more optimal place for a block:
--image--

This means that when placing a new block we need to:
0) Create an array of possible points for our block
1) Go through all candidate points
2) Check if placing a new block into a candidate point t would overlap with any other block B
  2.1) If it wouldn’t, add that candidate point to the possible points
  2.2) If it would, add a new point with modified y to the possible points and repeat 2) until there is no overlap
3) Find the lowest point in possible points

This is the first part of our block placing algorithm.

### Ghost blocks:
The second part of the project (optimized order of placing blocks) doesn’t have a point if we allow ghost blocks,
since every block will be placed in any free spot it can fit into.
However, we are trying to mimic real life packaging, and with that in mind we can’t allow blocks to pass through each other.

For each new block we are trying to place we will go through all candidate points, and check if, for that block placement, there would be any blocks above it.
If there aren’t any blocks above it, the placement is legal. Otherwise we place it on top of the block above it and check again, until the placement is legal.
We are already doing this in step 2.2 by incrementally increasing block height instead of just marking the candidate point as illegal.

We will also delete all the candidate points that are directly under any block, to reduce the future number of iterations.
Upon placing a block we check:
```
for p in candidate_points[]:
if p.x < A.x and p.x > B.x and p.z < B.z and p.z > A.z and p.y < A.y:
candidate_points.remove(p)
```
This is the deletion part of the block placing algorithm.

### Extra edge case
Lastly there is one more edge case that arises, that needs to be solved in order to keep algorithms optimality for each new block added.
--image--

To solve this we simply need to add 2 more candidate points when adding a new block:
(t_block_x.x, t_best_x.y, 0), (0, t_best_z.y, t_block_z.z)

--image-- 

## Forming an algorithm:
0) Array of candidate points and overlap control points. Candidate point is tuple (x,y,z). Overlap control point is tuple (x,y,z,width,depth).
1) Find the best point for a new block.
2) Add new candidate points
3) Add new overlap control points
4) Delete all illegal candidate points
5) Delete all unnecessary overlap control points

Maybe this problem can be solved in better time with the use of more complex structures, however we weren’t able to go below O(N * M * K), where:
N is the number of candidate points (with each new block we add up to 5 new candidate points and remove a minimum of 1 candidate point).
M is the number of overlap control points (with each new block we add 1 overlap control point, and can remove some of them), however we break upon finding the first overlap, which makes this number smaller in practice.
K is the number of levels a certain block would overlap with other blocks. This number will be higher if we have holes in our packaging structure and if there are a lot of candidate points on deeper levels. However in practice this number is really low and can be disregarded.
The time complexity of this part of the algorithm is therefore (in practice) no worse than O(M*N).

We can combine steps 2), 3) and 4) and do them simultaneously, to save time.

**Final version of the algorithm:**

0) Array of candidate points and overlap control points. Candidate point is tuple (x,y,z). Overlap control point is tuple (x,y,z,width,depth).
1) Find the best point for a new block. At worst O(N * M * K)
2) Update candidate points. At worst O(N), N = number of candidate points
3) Delete unnecessary overlap control points. O(M), M = number of overlap control points
