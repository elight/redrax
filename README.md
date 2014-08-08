# Redrax

<a href="https://codeclimate.com/github/elight/redrax/code">
  <img src="https://codeclimate.com/github/elight/redrax/badges/gpa.svg"></img>
</a>

<a href="https://travis-ci.org/elight/redrax">
  <img src="https://travis-ci.org/elight/redrax.svg"></img>
</a>

[![Dependency Status](https://gemnasium.com/elight/redrax.svg)](https://gemnasium.com/elight/redrax)

Redrax is a Rackspace-specific Ruby client for the Rackspace cloud.

# Goal

To be the best documented, easy to use, and easy to maintain and contribute to Rackspace client in Ruby.

Special attention is being given to 

* Consistency of idioms employed both within the implementation and on its own API
* Method documentation
* Rackspace cloud API documentation

A simple DSL was introduced to assicated method calls with their supporting API documentation.  This same DSL is used to augment backtraces resulting from these API calls with a link to the relevant API doc page as well as adding "See Also" links to the generated YARDocs to the same API doc pages.

# Status

As of 8/8/14, Redrax supports most Cloud Files features.  Ongoing development will focus on Cloud Servers and Cloud Block Storage.

# Contributing

We should be open to contribution after Cloud Servers is partially implemented.  The idioms employed within this library may change to accommodate Cloud Servers but also to be consistent between Cloud Servers and Cloud Files as appropriate.
