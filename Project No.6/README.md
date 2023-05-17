**1. INCORPORATING `sp.next()`**

- We can modify our existing code to include a while loop that iteratively fetches additional pages of tracks from the playlist using the `sp.next()` method,
which takes the current results as its argument and returns the next page of results.

- With this approach, the code will continue to fetch and process tracks from the playlist until there are no more tracks left to fetch.
It's important to note that calling sp.next() will return None when there are no more pages to fetch, which will cause the while loop to exit.


**2. RESULTS INTO DATAFRAME `spotipyData`**

- In order to store our results in a pandas DataFrame,
we can first store our results in a list of dictionaries where each dictionary corresponds to a track with its details,
and then convert this list to a DataFrame.


**3. GET AUDIO FEATURES**

- We can get the audio features of each track using the `sp.audio_features()` method.
This method requires the track ID as its argument and returns a list of dictionaries containing the audio features.

- In the code code below, `sp.audio_features(track_dict["track_id"])[0]` fetches the audio features for the current track
and the [0] indexing extracts the single dictionary from the returned list.

- The `track_dict.update(audio_features)` line then adds these audio features to the current track's dictionary.
Note that the update() method adds the keys and values from the audio_features dictionary to the track_dict dictionary.


**4. EXTRACT GENRE**

- The genre of a song is not directly provided in the track or album data from the Spotify Web API.
However, genre information can be found in the artist data.

- We can get the genres associated with the artists by making a request to the Spotify Web API for artist data using the artist's ID.
In Python, using the spotipy library, we can do this with the `sp.artist()` method.

- This will print out the list of genres associated with each of the artists.
> *Please note that this doesn't necessarily give the genre of the particular song,<br>
as artists often produce music across a variety of genres.<br>
But this will give we some idea about the genres the artists are commonly associated with.*

- From our code, it seems that we have a list of genres for each artist under the artistGenre key,
and we would like to keep only the first genre if multiple genres are available.

- Here's how we can do it:
```python
track_dict["artistGenre"] = artist_info["genres"][0] if artist_info["genres"] else None
```

- The line will check if the genres list is not empty.
If it's not empty, it will take the first genre; if it's empty, it will assign None.
- Please note that the genres returned from the Spotify API are sorted in order of relevance, with the most relevant genre listed first.


**5. INTERATE OVER TRACK URIs FROM MULTIPLE PLAYLIST**

- we can modify our script slightly to iterate over the playlist dictionary and include the playlist title in each track dictionary.

> *Please note that it's very important to ensure the rate limit is not exceeded when using Spotify API.<br>
If we are fetching a lot of data, it's possible we could exceed the rate limit and our requests will be throttled.<br>
If this happens, we might need to slow down our requests or use other strategies like caching.*


**6. USE OF CACHES TO AVOID EXCEEDING THE RATE LIMIT**

- Caching involves storing the results of expensive function calls and reusing the results when the same inputs occur again.
This can be particularly useful when dealing with APIs where there are rate limits,
as we can store the results of a particular API call
and simply use the cached result instead of making a new API call if we need that information again.

- In Python, we can use the `lru_cache` decorator from the functools library to easily cache the results of function calls.
- Here's a snippet of the code:
```python
from functools import lru_cache

@lru_cache(maxsize=1000)
def get_artist_info(artist_uri):
    return sp.artist(artist_uri)

@lru_cache(maxsize=1000)
def get_audio_features(track_id):
    return sp.audio_features(track_id)[0]
```

- The `lru_cache` decorator is a feature of Python's functools module that provides a simple way to add memoization to our functions. Memoization is a technique where the results of expensive function calls are cached and reused when the same inputs occur again.

- The `lru_cache` decorator creates a Least Recently Used (LRU) cache for a function. When the cache is full, the least recently used items are discarded.

- In our specific use case, `lru_cache` is used to avoid making the same API calls to Spotify multiple times for the same artist or track, which can save time and reduce the load on the Spotify API, helping to avoid hitting rate limits.

***Here's a breakdown of the decorator parameters:***

- `maxsize` is the maximum size of the cache. If it is set to None, the LRU feature is disabled and the cache can grow without bound.
- If `maxsize` is set to a positive integer, the decorator will keep the most recent maxsize distinct function calls.
- For example, `@lru_cache(maxsize=1000)` will keep a cache of the results of the most recent 1000 unique calls to the decorated function.

- In our code, the `get_artist_info` and `get_audio_features` functions are decorated with `lru_cache`,
which means that if we call these functions with the same `artist_uri` or `track_id` more than once,
the results of the first call will be returned from the cache instead of making a new API call.
This can significantly speed up our script and reduce the number of API calls made.

***What if we exceed?***
- The maxsize parameter of the lru_cache decorator sets the limit for how many unique calls are cached.
If this limit is reached (in our case, 1000 unique calls), and a new unique call is made,
then the least recently used item in the cache will be removed to make room for the new item.

- So, if we exceed 1000 unique calls, the decorator will still cache the results, but some of the older results will be discarded.
This mechanism ensures that the cache does not grow indefinitely, which could potentially use a lot of memory.

- If we expect to make more than 1000 unique calls and want to cache them all, we could increase the maxsize parameter.
However, keep in mind that the cache uses memory, so there's a trade-off between the amount of memory used and the number of calls cached.

- Also, it's important to note that the cache only benefits we if there are repeated calls with the same parameters.
If all calls are unique, the caching won't improve performance and can actually slow down the program slightly due to the overhead of maintaining the cache.

**7. HANDLE EXCEPTIONS CORRECTLY IN API CALLS**

- Handling exceptions in our API calls can be done using the try/except block in Python.
When a request fails, libraries like requests or spotipy usually raise an exception that we can catch and handle appropriately.

- Here's a snippet of the code:
```python
import time

# define maximum number of retries for the API call
max_retries = 5

for i in range(max_retries):
    try:
        # make the API call
        results = sp.playlist_tracks(playlist_id)

        # if the API call was successful, process the results
        # ...

    except spotipy.exceptions.SpotifyException as e:
        # if the exception is a rate limiting error (error 429), wait and retry
        if e.http_status == 429:
            print("Rate limit exceeded. Waiting...")
            time.sleep(int(e.headers.get('Retry-After', 10)))
        else:
            # if it's a different kind of error, we might want to handle it differently,
            # or re-raise the exception if it's not something our script can recover from
            raise e
```

***This is an example of exception handling in Python for managing API call failures. Here's what it does:***

1. `import time`: This imports the `time` module, which provides various time-related functions.
Here, it's used for the `sleep` function, which pauses execution of the script for a specified number of seconds.

2. `max_retries = 5`: This line sets a variable that determines the maximum number of times the script will try to call the API if an exception occurs.

3. `for i in range(max_retries)`: This starts a loop that will run up to `max_retries` times.

4. `try:`: This begins a `try` block.
The code inside this block is executed normally, but if any exceptions (errors) occur,
instead of stopping the program, control is passed to the `except` block.

5. `results = sp.playlist_tracks(playlist_id)`: This line is where the API call is made.
If the call is successful, the results are stored in the `results` variable.
If an error occurs during the call, an exception is raised, and control is passed to the `except` block.

6. `except spotipy.exceptions.SpotifyException as e:`: This begins an `except` block, which is where we define what to do when an exception occurs.
This block will only handle exceptions of type `SpotifyException`,
which are the exceptions that the `spotipy` library defines for errors that occur when making Spotify API calls.

7. `if e.http_status == 429:`: If the HTTP status code of the exception is 429, it means that the rate limit has been exceeded.
In this case, the script waits for a certain amount of time before retrying the API call.
The wait time is taken from the `Retry-After` header of the response, or defaults to 10 seconds if the header is not present.

8. `else: raise e`: If the HTTP status code of the exception is not 429, the exception is re-raised.
This will stop the execution of the script and show the error message,
unless the exception is caught and handled by another `try`/`except` block somewhere else in our code.
This is useful for catching unexpected errors that our script doesn't know how to handle.

The purpose of this code is to gracefully handle API call failures due to rate limiting,
by waiting and retrying the call instead of stopping the script with an error.
It also sets a limit on the number of retries to avoid an infinite loop in case of persistent errors.

***What if we exceed all the tries?***

- If the code exceeds the 5 retries that we specified in `max_retries`,
the loop will simply stop and the script will continue to execute the code that follows it. 

- If the last attempt (the 5th in this case) results in an exception,
the exception will be raised (due to the `raise e` statement in the `else` clause of the `except` block) and the script execution will stop,
unless the exception is caught and handled by another `try`/`except` block somewhere else in our code.

- Essentially, after 5 failed attempts,
the script will not try again and will either continue to the next section of code or stop,
depending on whether the last attempt raised an exception.
This is a simple way of preventing our script from getting stuck in an infinite loop of retries if the API call continues to fail.