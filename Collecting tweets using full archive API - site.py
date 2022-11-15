#!/usr/bin/env python
# coding: utf-8

# In[1]:


# For sending GET requests from the API
import requests
# For saving access tokens and for file management when creating and adding to the dataset
import os
# For dealing with json responses we receive from the API
import json
# For displaying the data after
import pandas as pd
# For saving the response data in CSV format
import csv
# For parsing the dates received from twitter in readable formats
import datetime
import dateutil.parser
import unicodedata
#To add wait time between requests
import time


# In[3]:


bearer_token='AAAAAAAAAAAAAAAAAAAAAHXvUQEAAAAAPQ%2FXl8vv2ZxuPlNEMn%2BbAvOg428%3DCNmiqFmvchzJIzzhLvyFBvL1mnOuwGjALg6uSbECpZIojXxUIM'


# In[4]:


os.environ['TOKEN'] = 'AAAAAAAAAAAAAAAAAAAAAHXvUQEAAAAAPQ%2FXl8vv2ZxuPlNEMn%2BbAvOg428%3DCNmiqFmvchzJIzzhLvyFBvL1mnOuwGjALg6uSbECpZIojXxUIM'


# In[5]:


def auth():
    return os.getenv('TOKEN')


# In[6]:


def create_headers(bearer_token):
    headers = {"Authorization": "Bearer {}".format(bearer_token)}
    return headers


# In[7]:


def create_url(keyword, start_date, end_date, max_results = 10):
    
    search_url = "https://api.twitter.com/2/tweets/search/all" #Change to the endpoint you want to collect data from

    #change params based on the endpoint you are using. In the case of the full-archive search endpoint, 
    #the *query* parameter is the only parameter that is **required** to make a request. 
    #The query parameter is where you put the keyword(s) you want to search for.
    query_params = {'query': keyword,
                    'start_time': start_date,
                    'end_time': end_date,
                    'max_results': max_results,
                    'expansions': 'author_id,in_reply_to_user_id,geo.place_id',
                    'tweet.fields': 'id,text,author_id,in_reply_to_user_id,geo,conversation_id,created_at,lang,public_metrics,referenced_tweets,reply_settings,source',
                    'user.fields': 'id,name,username,created_at,description,public_metrics,verified',
                    'place.fields': 'full_name,id,country,country_code,geo,name,place_type',
                    'next_token': {}}
    return (search_url, query_params)


# In[8]:


def connect_to_endpoint(url, headers, params, next_token = None):
    params['next_token'] = next_token   #params object received from create_url function
    response = requests.request("GET", url, headers = headers, params = params)
    print("Endpoint Response Code: " + str(response.status_code))
    if response.status_code != 200:
        raise Exception(response.status_code, response.text)
    return response.json()


# In[9]:


bearer_token = auth()
headers = create_headers(bearer_token)
keyword = "xbox lang:en"
start_time = "2021-03-01T00:00:00.000Z"
end_time = "2021-03-31T00:00:00.000Z"
max_results = 15


# In[10]:


url = create_url(keyword, start_time,end_time, max_results)
json_response = connect_to_endpoint(url[0], headers, url[1])


# In[11]:


print(json.dumps(json_response, indent=4, sort_keys=True))


# In[12]:


json_response['data'][0]['created_at']


# In[13]:


json_response['meta']['result_count']


# In[14]:


with open('data.json', 'w') as f:
    json.dump(json_response, f)


# In[ ]:




