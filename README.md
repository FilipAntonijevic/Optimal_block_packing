Optimal block packing

In this problem, we are trying to find an optimal way to pack n pseudo randomly generated blocks into a container. 
We are trying to minimize container height, while still being able to pack all of the blocks.
This means we need to find best order in which we are going to be placing blocks into the container.

Program consists of two parts:
1) Block placing algorithm
2) Finding optimal order of placing blocks

**Block placing algorithm:**
Initial idea:
We are trying to make Block placign algorithm that:
1) Doesnt allow illegal block states
2) Is optimal for a certain order of blocks
3) Is fast

In order for algorithm to be optimal it has to be able to always place next block in the lowest possible space.

Container is absolutely continuous. 
This means that we need to save all possible points that we can place block into, in some structure, that we can easily iterate through.
We will call these points candidate points.

We want to place as many blocks as possible on each level. 
With this in mind its trivial to deduce that placing blocks right next to each other, and next to container walls, is better then placing blocks randomly onto said level, since it leaves more space for other blocks to fit into.

It follows that optimal place for first block is in (0,0,0).
Next block is either next to first block (on either side, if it can fit), or in (0,first block height, 0), if it cannot fit.
--image--

We can define our block placing algorithm with:
0) Structure that holds all our candidate points
1) Part of algorithm that can iterate through said structure and easily find best possible spot for next block
2) Part of algorithm that adds new candidate points to the structure, for future blocks to be added into
3) Part of algorithm that removes all illegal points from the structure

In order to understand the need for all of these parts, we need to remember our first condition for good block placing algorithm:
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

This is deletion part of block placing algorithm.

Floating blocks:
In order to solve floating blocks we need to solve this edgecase:
--image--
As we can see its not enough to simpy add points A, B and C as new candidate points. 
Lets focus on point A:
We want dont want candidate point to be A. 
Instead we want (A.x , p_best_A.y, A.z) to be next candidate point, where p_best.y value is height of the block directly underneath point A.
We can find this point p_best by going through all other points that have smaller x, y and z then our block, and finding a closest one to it:
For our condition on which candidate points are possible we use:
  if p.x <= A.x and p.y <= A.y and p.z <= A.z:
And to find closest one (in a top down 2d view):
  p_best_A = p_i | max((p_i.x + 1) * (p_i.z + 1)) for every i
We added + 1 to each coordinate, to avoid multiplication with a 0 value.

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
This problem is hardest to solve and demands expanding on our candidate points structure.

When placing a block into a candidate point, we need to be able to check if that block will overlap with any other block:
--image--

For each candidate point p we need to check if the new block will intersect any other block. 
This means we need to have to save some information about block size aswell as candidate points.

We will have 2 arrays one for candidate points and other for control points (to check for overlaps), and then with each new block, besides updating candidate points, we need to add that blocks overlap control point to contorl points array.
--image---- image --

Overlap control point besides (x,y,z) has blocks width and blocks depth. 
This isnt enough to recreate whole block, but we dont have to. We only need to check if block will intersect with any of the rectangles above it in top down 2d view:
--image--

What if already placed block A would be above block B, if we place it into candidate point p, but they wouldnt intersect?
--image--
We mark candidate point p as illegal for block B, since that would be a ghost block.

However, its not enough to just find lowest candidate point that doesnt doesnt allow for overlaping blocks, because there might be more optimal place for a block:
--image--

This means that when placing a new block we need to:
0) create an array of possible points for our block
1) go through all candidate points
2) check if placing a new block into a candidate point t would overlap with any other block B
     2.1) if it wouldnt add that candidate point to the possible points
     2.2) if it would add new point with modified y to the possible points and repeat 2) until there is no overlap
3) find the lowest point in possible points


Final version of algorithm:
0) Array of candidate points and overlap control points. Candidate point is tuple (x,y,z) Overlap control point is tuple (x,y,z,width,depth).
1) Find best point for a new block. At worst O(N * M * K)
2) Add new candidate points
3) Add new overlap control points
4) Delete all illegal candidate points
5) Delete all unnecessary overlap control points

Maybe this problem can be solved in better time with a use of more complex structures, however we werent able to go below O(N * M * K), where:
N is number of candidate points (with each new block we add up to 3 new candidate points and remove minimum of 1 candidate points), 
M is number of overlap control points ((with each new block we add exactly 4 overlap control points, and can remove some of them), however we break upond finding first overlap,
K is number of levels a certain block would overlap with other blocks. This number will be higher if we have holes in our packaging structure and if there are a lot of candidate points on deeper levels. However its usualy small and time complexity is usualy no worse than O(M*N).

We can combine steps 2) 3) 4) and do it simultaneously, to save up time.

Final version of algorithm:
0) Array of candidate points and overlap control points. Candidate point is tuple (x,y,z) Overlap control point is tuple (x,y,z,width,depth).
1) Find best point for a new block. At worst O(N * M * K)
2) Update candidate points. At worst O(N), N = number of candidate points
3) Delete unnecessary overlap control points. O(M), M = number of overlap control points

Now we made relatively fast algorithm that doesnt allow illegal states. But is it optimal for a predetermened order of blocks?
It isnt. There is an edgecase that with our current implementation isnt solvable:
--image--
However it isnt imperative to make it optimal, since we can rely on optimizing block order, to find close to optimal solutions.
