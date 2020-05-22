# Data

Data was downloaded from [IMDB](https://datasets.imdbws.com/). 

Documentation for these data files can be found [HERE](http://www.imdb.com/interfaces/).

In particular, `title.basics.tsv.gz` and `title.ratings.tsv.gz` were used to create this app.

## Preprocessing

Not all data in the files mentioned above is shown in this app. 

The following filters were applied to create the final `movies` data set used by the app:

- `titleType`== "movie",
- `startYear` >= 1980,
- `runtimeMinutes`: [45;210],
- `averageRating` >= 6,
- `numVotes` >= 2500

This means that this app shows **movies** from 1980 to today, with a duration between 45min and 3h30min, with an average rating of 6 or more on IMDB and at least 2500 votes.

# App

The app consists of a sidebar, a plot and a table. 

You can use the **sidebar** to apply filters to the movies shown in the plot and table. A movie can have at most 3 genres.

Each point in the **plot** represents a movie. The axis are *Number of Votes* and *Average Rating*. You can hover over a point to see what movie it is. Also, you can use the *Select* buttons of the graph to choose certain points. You can also *Zoom* where you want. If you want to return to the default view, you can double click in the graph or use the *Reset axes* button.

The **table** shows detailed information of the movies that follow the filters you applied, and/or that you *selected* in the plot. By default, movies are ordered by number of votes. This can be modified by clicking the columns. Also, the title is linked to the movie's IMDB website.

# Code

You can check the code used to produce this app in my [Github Repo](https://github.com/IvanM26/MoviePicker).