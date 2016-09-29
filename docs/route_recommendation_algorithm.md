# Route Recommendation Algorithm

Overview Algorithm for cleaning and rating routes retrieved from Google Directions:

```
-1  LOW SAFETY
 0 MODERATE
 1 SAFE
```

1. Grab SaferStreets grid for a particular area that covers origin and destination.
2. Make the grid into smaller chuncks (3x3 per grid), because the original size is 500m x 500m and it's too large. After this process, the grid size is 166.67m x 166.67m.
3. Find the safest path using [A* path finding algorithm](http://web.mit.edu/eranki/www/tutorials/search/). The grid cost is based on grid's safety level: (1: Moderately Safe, 2: Moderate, 4: Low Safety). We don't use negative cost because A* only work for positive number. The "Moderately Safe" cost is 1 instead of 0, because we need to walk on that grid and it takes time (cost) too.
4. Ask Google Directions for A* waypoints result. The waypoint is taken from center of result grids. We only use "corner" grid as waypoint, because Google Directions only able to compute upto 23 waypoints.
5. Refine the path using modified [Reumann-Witkam](http://www.codeproject.com/Articles/114797/Polyline-Simplification#headingRW) polyline simplification algorthm. We use 166 m as distance tolerance.
6. Ask Google Direction for refined path above.