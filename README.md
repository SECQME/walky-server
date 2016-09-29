# safewalk-server
Safewalk Server

## Dependencies

This instruction is for Ubuntu 14.04.

Install PostgreSQL client connector library:

```sh
sudo apt-get install libpq-dev
```

Install [GEOS](https://trac.osgeo.org/geos) and [PROJ](https://trac.osgeo.org/proj).
This libraries are required by [RGeo](https://github.com/rgeo/rgeo) gem.
You **must** run `bundle install` **after** GEOS and PROJ are installed, or RGeo will be not compiled with native libraries.

```sh
sudo apt-get install libgeos-dev libproj-dev

# You can run Ruby dependencies
bundle install

# Fix GEOS undetected library
sudo ln -s /usr/lib/libgeos-*.so /usr/lib/libgeos.so
sudo ln -s /usr/lib/libgeos-*.so /usr/lib/libgeos.so.1
```

Detect GEOS and PROJ are loaded by Rails:

```sh
# Open Rails console
rails console

# Run this code in the console
RGeo::Geos.supported?             # Should return true
RGeo::CoordSys::Proj4.supported?  # Should return true
```

Walky requires the `saferstreets-server` project to be setup & its database to exist in order to properly run.
