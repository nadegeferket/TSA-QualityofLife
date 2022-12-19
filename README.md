# Twitter sentiment analysis 
## Data Collection 
The following code snippet allows you to collect your own dataset using the Full-Archive Search API of Twitter.
```python
from utils.data_collection import DataLoader

bearer_token = " " 
dl = DataLoader(bearer_token)   #Insert your bearer token here

#Retrieve around 200 tweets, 100 on 2022/01/01 and 100 on 2022/01/02, written in English
tweet_list = dl.retrieve_tweet(start_list=['2022-01-01T00:00:00.000Z','2022-01-02T00:00:00.000Z'],
                               end_list=['2022-01-02T00:00:00.000Z','2022-01-03T00:00:00.000Z'],
                               keyword="lang:en",
                               tweet_per_period=100
                               )
                               
#Convert the Twitter json output to csv  and save files                             
tweet, user = dl.to_dataframe(tweet_list)
tweet.to_csv('output_path')
user.to_csv('output_path')
```
## Twitter sentiment classifier 
For the classification of the sentiment the collected tweets are containing, the 'vlaams-twitter-sentiment-model' of Statistics Flanders is used.
```python
from twitter_sentiment_classifier import batch_predict

texts = [
    'Ik haat u!',  # Negative
    'Daar ben ik het mee eens',  # Neutral
    'Ik hou van je!'  # Positive
]

batch_predict(texts)
```
