# Quality of Life in Flanders: a Comparative Study Using Twitter and Survey Data
In this repository, the code implementation can be found of the KU Leuven Master's Thesis "Quality of Life in Flanders: a Comparative Study Using Twitter and Survey Data", written by Sarah Vranken and Nadège Ferket in the academic year 2022-2023 under the supervision of Manon Reusens and Prof. Dr. Bart Baesens. The project was conducted in partnership with Statistics Flanders, represented by Dr. Michael Reusens. This dissertation investigates the use of social media data - Twitter data in particular - as a proxy and/or complement to survey data. Twitter data, based on Quality of life, is held next to a survey examining the Quality of Life of the Flemish population. Quality of life is divided in 3 domains and 8 subdomains. 
## Data collection 
The following code snippet allows you to collect your own dataset per region and year using the Full-Archive Search API of Twitter. For each subdomain, 10-15 keywords are defined in order to collect enough and accurate tweets for our research. 
```python
import pandas
dl = DataLoader(bearer_token)   

#Retrieve around 200 tweets, 100 on 2020/01/01 and 100 on 2020/01/02, written in English
tweet_list = dl.retrieve_tweet(start_list=['2020-01-01T00:00:00.000Z','2020-02-01T00:00:00.000Z'],
                               end_list=['2020-01-31T00:00:00.000Z','2020-02-28T00:00:00.000Z'],
                                keyword="overheid place_country:BE has:geo lang:nl",
                               tweet_per_period=100, 
                               )
                               
#Convert the Twitter json output to csv  and save files 

tweet, user = dl.to_dataframe(tweet_list)

colnames = ["1","Antwerpen","Limburg","Oost_Vlaanderen","West_Vlaanderen","Vlaams_Brabant","Brussel"]
namenPerProvincie = pandas.read_csv('provincies_officieel.csv', names=colnames) 
stedenList = namenPerProvincie.Antwerpen.tolist()[1:] #Geef provincie in

rslt_df = tweet[tweet['location_geo'].isin(stedenList)]
rslt_df.to_csv('tweet_output_path3.csv')
user.to_csv('user_output_path3.csv')

```
## Twitter sentiment classifier
For the classification of the sentiment the collected tweets are containing, the 'vlaams-twitter-sentiment-model' of Statistics Flanders is used.
```python
from twitter_sentiment_classifier import batch_predict

import pandas
colnames = [ c for c in "abcdefghujklmnopqrst"]
data = pandas.read_csv('Downloads\\tweet_output_path2.csv', names=colnames) #geef eigen doc in
texts = data.o.tolist()[1:]
for i in range(0,len(texts)):
    #preprocessing stap: vervangen van einde lijn naar spatie
    texts[i] = texts[i].replace("\n"," ")
    
output_df= batch_predict(texts) 
df = pandas.DataFrame(output_df)
writer = pandas.ExcelWriter('sentiment_dieet_Antw.xlsx', engine='xlsxwriter') #geef eigen doc in
df.to_excel(writer, sheet_name='sentiment_tweets', index=False)
writer.save()
```

## Subjective Well-Being
Once the classification is done, QoL needs to be substracted from these findings. For this we follow the multiple papers Iacus wrote about QoL. His code, however, is in R rather than Python as the rest of the research is. Therefore, notebooks are created based on the research of Iacus.

## Mitigating migration bias
In order to do this, Programmatic Weak Supervision (PWS) is used to mitigate migration bias. Migration bias is specific to this research, because a person sending a message in Flanders is not necessarily Flemish, but the residence can be travel or work related. This bias occurs from location being a self-reported string.  
