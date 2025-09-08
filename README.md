Optimal block packing

In this problem, we are trying to find an optimal way to pack n pseudo randomly generated blocks into a container. 
We are trying to minimize container height, while still being able to pack all of the blocks.
This means we need to find an order in which we are going to be placing blocks into the container.

Program consists of two parts:
1) Block placing algorithm
2) Finding optimal order of placing blocks

Block placing algorithm:
Initial idea:
We are trying to make Block palcign algorithm that:
1) Is optimal for a certain order of blocks
2) Doesnt allow illegal block states
3) Is fast

In order for algorithm to be optimal it has to be able to always place next block in the lowest possible space.

Container is absolutely continuous. 
This means that we need to save all possible points that we can place block into, in some structure, that we can easily iterate through.
We will call these points candidate points.

We want to place as many blocks as possible on each level. 
With this in mind its trivial to deduce that placing blocks right next to each other, and next to container walls, is better since it leaves more space
for other blocks to fit, then placing blocks randomly onto said level.

With this in mind, we can safely assume that, optimal place for first block is in (0,0,0).
Next block is either next to first block (on either side, if it can fit), or in (0,first block height, 0), if it cannot.
--image--

We are trying to create algorithm that has:
0) Structure that holds all our candidate points
1) Part of algorithm that can iterate through said structure and easily find best possible spot for next block
2) Add new candidate points to the structure
3) Remove illegal points from the structure

In order to understand these terms, we need to remember our second condition for block placing algorithm:
"Doesnt allow illegal block states"

Illegal block states are:
1) Outside blocks - Blocks outside container
2) Ghost blocks - blocks that pass through another block while falling into a space
3) Floating blocks - blocks that can, but dont fall down to the lowest possible space underneath them
4) Overlaping blocks - blocks that when places overlap with already placed blocks

Outside blocks:
By checking if block can fit in a space before placing it in that candidate point, we already solved Outside blocks.

Ghost blocks:
Second part of the project (optimised order of placing blocks) doesnt have a point if we allow ghost blocks, 
since every block will be placed in any free spot it can fit into.
However, we are trying to mimic real life packaging, and in that in mind we cant allow blocks to pass through each other.

We will achieve this by deleting all the candidate points that are directly under any block.
Upon placing a block we check:
for p in candidate_points[]:
  if p.x < A.x and p.x > B.x and p.z < B.z and p.z > A.z and p.y < A.y:
    candidate_points.remove(p)

This deletion part of block placing algorithm.

Floating blocks:
In order to solve floating blocks we need to solve this edgecase:
--image--
As we can see its not enough to simpy add points A, B and C. 
Lets focus on lower points (A and B).
We need to add new candidate point (A.x , p_best_A.y, A.z). This p_best.y value is lowest possible point we can place new block into (for a x = A.x and z = A.z)
We can find this point p_best by going through all other points that have smaller x and z then our block, and finding a closest one to it:
For our condition on which candidate points are possible we use:
  if p.x <= A.x and p.y <= A.y and p.z <= A.z:
And to find closest one (in a top down 2d view):
  p_best_A = p_i | max(p_i.x, p_i.y) for every i

Finding actual candidate point for point B is analog.
Even tho it may seem like C will always be candidate point we can see that is not the case in this image:
--image--

This means we need to repeat similar process for finding candidate point for C point. 
This candidate point will be (p_best_C.x , C.y, p_best_C.z)
And p_best_C we are finding in subset of all candidate points that meet the condition:
  if p.x <= A.x and p.y <= A.y and p.z <= A.z:
and we out of all those points we select the highest one:
  p_best_C = p_i | max(p_i.y) for every i

This is candidate point adding part of the algorithm.

Overlaping blocks:
This problem is hardest to solve and demands restructuring our candidate points structure, and adding 4 more points to it with each block.
When placing a block into a candidate point, we need to be able to check if that block will overlap with any other block:
--image--

For each candidate point p we need to check if block will intersect any toher block. 
This means we need to have to save some information about block size aswell as candidate points.

We did it like this:
When saving a block we add all four of its top points:
-- image --
And with each point we will also save block width and block depth.
This isnt enough to recreate whole block, but we dont have to. We only need to check if block will intersect with any of the rectangles above it in top down 2d view:
--image--

What if already placed block A would be above block B, if we place it into candidate point p, but they wouldnt intersect?
--image--
We mark candidate point p as illegal for block B, since that would be a ghost block.

Algorithm
0) Array of candidate points. Candidate point is tuple (x,y,z,width,depth)
1) Go through all point in algorithm and find lowest legal point. Place block in it.
2) Add new candidate points
3) Delete all illegal candidate points


