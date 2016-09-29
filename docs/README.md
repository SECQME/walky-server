# Walky-Server

Walky-Server is a web API for Walky navigation app.

Tech Stack:

* Ruby 2.1.1
  * Rails 4.2.3
  * RGeo 0.5
  * Rack-CORS
* PostgreSQL 9.4
  * PostGIS 2.2
  * pgRouting 2.2
  * kmeans-postgres 1.1
* Passenger 5.0 (App server)
* Capistrano 3

## Important API endpoint

### Direction/Routing

There are two version:

* `Api::V1::RoutingController`: Edge based routing using pgRouting
* `Api::V1::DirectionsController`: *Deprecated*, grid based navigation

In this section, `RoutingController` only will be explained:

1. Ensure the straight distance < 10 km.
2. Return if there is matched routes in cache.
3. Find route from origin to destination using pgRouting (`EdgeBasedRouteEngine` service).
   1. Create a bounding box for make narrow area + much faster result
   2. Find nearest origin and destination edge
   3. Build pgRouting query based on origin, destination, and bounding box. We use [`pg_trsp`](http://docs.pgrouting.org/2.2/en/src/trsp/doc/pgr_trsp.html#trsp) algorithm.
   4. Cut the first and last edge, to make start point and end point are nearby origin and destination.
   5. Construct the lines into Google Maps Direction format.
4. Find route using Google Maps Directions API, we use [`google_maps_service`](https://rubygems.org/gems/google_maps_service/) gem.
5. Rate the routes using (`RouteRatingService` service).
   1. Pull the covered cities, grids, and zones information based on bounding box
   2. For each routes, ensure the distance between points in the route no more than a half of the grid size.
   3. If the point is lied on a zone, return the zone rating.
   4. If the point is lied on a grid, return the grid rating.
   5. Otherwise, return unknown rating.
6. Sort the result based on rating.
7. Cache the result.

### Reports/Clustering

There are two version:

* `Api::V2::ReportsController`: Clustered reports.
* `Api::V1::ReportsController`: *Deprecated*. Reports only.

In this section, `Api::V2::ReportsController` only will be explained. This endpoint takes two parameters, i.e. `bounds` and `zoom_level`. 

* `bounds`: Bounding box, in format `{sw_lat},{sw_lng}|{ne_lat},{ne_lng}`, e.g: `41.835345,-87.623239|41.839009,-87.618085`.
* `zoom_level`: (Google) Maps zoom level from mobile view.

The clustering is based on `zoom_level`:

```
case @zoom_level
  when 0..1
    @clusters = @clustering_service.column_names_clusters('country')
    @reports = []
  when 2..4
    @clusters = @clustering_service.column_names_clusters('country', 'state')
    @reports = []
  when 5..9
    @clusters = @clustering_service.column_names_clusters('country', 'state', 'city')
    @reports = []
  when 10
    @clusters = @clustering_service.kmeans_clusters(9)
    @reports = []
  when 11..12
    @clusters = @clustering_service.kmeans_clusters(12)
    @reports = []
  when 13..16
    @clusters = @clustering_service.kmeans_clusters(16)
    @reports = []
  else
    @clusters = []

    @total_reports = find_reports.count
    @reports = find_reports.limit(@per_page).offset((@page - 1) * @per_page)
  end
```

The cluserters from the above may have some overlap clusters. To remove overlap, we merge some nearby clusters to a single clusters using [hierarchical agglomerative clustering using median linkage](https://en.wikipedia.org/wiki/Hierarchical_clustering). Read the hierarchical agglomerative clustering from [this SciPy tutorial](https://joernhees.de/blog/2015/08/26/scipy-hierarchical-clustering-and-dendrogram-tutorial/) and [MATLAB documentation](http://www.mathworks.com/help/stats/linkage.html).