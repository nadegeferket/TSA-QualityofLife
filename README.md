# Quality of Life in Flanders: a Comparative Study Using Twitter and Survey Data
In this repository, the code implementation can be found of the KU Leuven Master's Thesis "Quality of Life in Flanders: a Comparative Study Using Twitter and Survey Data", written by Sarah Vranken and Nadège Ferket in the academic year 2022-2023, and under the supervision of Manon Reusens and Prof. Dr. Bart Baesens. The project was conducted in partnership with Statistics Flanders, represented by Dr. Michael Reusens. This dissertation investigates the use of social media data - Twitter data in particular - as a proxy and/or complement to survey data. Twitter data, based on Quality of life, is held next to a survey examining the Quality of Life of the Flemish population. Quality of life is divided in three domains and eight subdomains. 
## Data collection 
The following code snippet allows you to collect your own dataset per region and year using the Full-Archive Search API of Twitter. For each subdomain, 10-15 keywords are defined in order to collect enough and accurate tweets for our research. The code for this is inspired by https://github.com/jtonglet/Demographics-PWS/blob/main/utils/data_collection.py
```python

import pandas
dl = DataLoader(bearer_token)   

#Retrieve around 200 tweets, 100 on 2020/01/01 and 100 on 2020/01/02, written in English
tweet_list = dl.retrieve_tweet(start_list=['2017-01-01T00:00:00.000Z','2017-02-01T00:00:00.000Z',
                                          '2017-03-01T00:00:00.000Z','2017-04-01T00:00:00.000Z',
                                          '2017-05-01T00:00:00.000Z','2017-06-01T00:00:00.000Z',
                                          '2017-07-01T00:00:00.000Z','2017-08-01T00:00:00.000Z',
                                          '2017-09-01T00:00:00.000Z','2017-10-01T00:00:00.000Z',
                                          '2017-11-01T00:00:00.000Z','2017-12-01T00:00:00.000Z'],
                               end_list=['2017-01-31T00:00:00.000Z','2017-02-28T00:00:00.000Z',
                                        '2017-03-31T00:00:00.000Z','2017-04-30T00:00:00.000Z',
                                        '2017-05-31T00:00:00.000Z','2017-06-30T00:00:00.000Z',
                                        '2017-07-31T00:00:00.000Z','2017-08-31T00:00:00.000Z',
                                        '2017-09-30T00:00:00.000Z','2017-10-31T00:00:00.000Z',
                                        '2017-11-30T00:00:00.000Z','2017-12-31T00:00:00.000Z'],
                                keyword="mindfulness place_country:BE has:geo lang:nl",
                               tweet_per_period=100, 
                               )
                               
#Convert the Twitter json output to csv  and save files 

tweet, user = dl.to_dataframe(tweet_list)
tweet.to_csv('tweet_info2017mindfulness.csv')
user.to_csv('user_info2017mindfulness.csv')

#Divide the data into 5 different files according to Flemish region and all of its subregions in the Flemish_regions file (French equivalents also added)

df_provincie = pd.read_csv("Flemish_regions.csv")
provincieNamen = ["Limburg","Antwerpen","Vlaams_Brabant","West_Vlaanderen","Oost_Vlaanderen"]
steden_per_provincie = [df_provincie[s] for s in provincieNamen]
for i in tqdm(range(0,len(steden_per_provincie))):
    rslt_df = tweet[tweet['location_geo'].isin(steden_per_provincie[i])]
    rslt_df.to_csv("tweet_per_provincie_" + provincieNamen[i] + "famleden" + ".csv")

```
## Twitter sentiment classifier
For the classification of the sentiment the collected tweets are containing, the 'vlaams-twitter-sentiment-model' of Statistics Flanders is used (link to their Github: https://github.com/vsa-datascience/vlaams-twitter-sentiment-model). Small steps of pre-processing of the Tweets are added in order to eliminate errors in the process. 
```python

from twitter_sentiment_classifier import batch_predict

import pandas
data = pandas.read_csv('Downloads\\tweet_per_provincie_welvarendOost_Vlaanderen.csv') #geef eigen doc in
texts = data['text']
lijst = list(texts)
for i in range(0,len(texts)):
    #preprocessing stap: errors elimineren
    lijst[i] = lijst[i].replace("\n"," ")
    lijst[i] = lijst[i].replace("\t"," ")
    lijst[i] = lijst[i].replace("\r"," ")
    
batch_predict(lijst) 
```

## Subjective Well-Being
Once the classification is done, QoL needs to be substracted from these findings. For this we follow the multiple papers Iacus wrote about QoL. His code, however, is in R rather than Python as the rest of the research is. Therefore, notebooks are created based on the Subjective Well-Being Index of Iacus et al. (2020) Controlling for Selection Bias in Social Media Indicatorsthrough Official Statistics: a Proposal. 

All sentiments of one region and domain is being merged and used in a calculation in order to derive the SWB index, for example, for the region Antwerp and the subdomain Emotional well-being:
```python
import pandas as pd

df = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_depressie_Antw.xlsx')
df1 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_droevig_Antw.xlsx')
df2 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_eenzaam_Antw.xlsx')
df3 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_gelukkig_Antw.xlsx')
df4 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_gevoelens_Antw.xlsx')
df5 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_hoopvol_Antw.xlsx')
df6 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_somber_Antw.xlsx')
df7 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_tevreden_Antw.xlsx')
df8 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_veerkracht_Antw.xlsx')
df9 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_vreugde_Antw.xlsx')
df10 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_wanhoop_Antw.xlsx')
```
```python

list0 = df.values.tolist()
list1 = df1.values.tolist()
list2 = df2.values.tolist()
list3 = df3.values.tolist()
list4 = df4.values.tolist()
list5 = df5.values.tolist()
list6 = df6.values.tolist()
list7 = df7.values.tolist()
list8 = df8.values.tolist()
list9 = df9.values.tolist()
list10 = df10.values.tolist()
listmax=list0+list1+list2+list3+list4+list5+list6+list7+list8+list9+list10
```
```python
out = []
for sublist in listmax:
    out.extend(sublist)
    
out

pos= out.count('POSITIVE')
neg= out.count('NEGATIVE')
neu= out.count('NEUTRAL')

percentpos= pos/len(out)
percentneg= neg/len(out)

SWBI= percentpos/(percentpos+percentneg)
```
## Investigating migration bias
Migration bias is specific to this research, because a person sending a message in Flanders is not necessarily Flemish, but the residence can be travel or work related. This bias occurs from location being a self-reported string. In order to investigate this bias, the modal tweet method is used, based on Armstrong et al. (2021) Challenges when identifying migration fromgeo-located Twitter data. The location history of a set of 442 users is extracted and examined. These users are then categorized in 5 different types: students, commuters, beach-visitors, foreigners and non-classified. The following code retrieves the location history of a given user and divides the years 2014-2018 into 20 different pieces, with time intervals of 3 months.
```python
from datetime import datetime
dl = DataLoader(bearer_token)   

#Retrieve around 200 tweets, 100 on 2020/01/01 and 100 on 2020/01/02, written in English
tweet_list = dl.retrieve_tweet(start_list=['2014-01-01T00:00:00.000Z','2014-02-01T00:00:00.000Z',
                                          '2014-03-01T00:00:00.000Z','2014-04-01T00:00:00.000Z',
                                          '2014-05-01T00:00:00.000Z','2014-06-01T00:00:00.000Z',
                                          '2014-07-01T00:00:00.000Z','2014-08-01T00:00:00.000Z',
                                          '2014-09-01T00:00:00.000Z','2014-10-01T00:00:00.000Z',
                                          '2014-11-01T00:00:00.000Z','2014-12-01T00:00:00.000Z',
                                           
                                          '2015-01-01T00:00:00.000Z','2015-02-01T00:00:00.000Z',
                                          '2015-03-01T00:00:00.000Z','2015-04-01T00:00:00.000Z',
                                          '2015-05-01T00:00:00.000Z','2015-06-01T00:00:00.000Z',
                                          '2015-07-01T00:00:00.000Z','2015-08-01T00:00:00.000Z',
                                          '2015-09-01T00:00:00.000Z','2015-10-01T00:00:00.000Z',
                                          '2015-11-01T00:00:00.000Z','2015-12-01T00:00:00.000Z',
                                           
                                          '2016-01-01T00:00:00.000Z','2016-02-01T00:00:00.000Z',
                                          '2016-03-01T00:00:00.000Z','2016-04-01T00:00:00.000Z',
                                          '2016-05-01T00:00:00.000Z','2016-06-01T00:00:00.000Z',
                                          '2016-07-01T00:00:00.000Z','2016-08-01T00:00:00.000Z',
                                          '2016-09-01T00:00:00.000Z','2016-10-01T00:00:00.000Z',
                                          '2016-11-01T00:00:00.000Z','2016-12-01T00:00:00.000Z',
                                           
                                          '2017-01-01T00:00:00.000Z','2017-02-01T00:00:00.000Z',
                                          '2017-03-01T00:00:00.000Z','2017-04-01T00:00:00.000Z',
                                          '2017-05-01T00:00:00.000Z','2017-06-01T00:00:00.000Z',
                                          '2017-07-01T00:00:00.000Z','2017-08-01T00:00:00.000Z',
                                          '2017-09-01T00:00:00.000Z','2017-10-01T00:00:00.000Z',
                                          '2017-11-01T00:00:00.000Z','2017-12-01T00:00:00.000Z',
                                          '2018-01-01T00:00:00.000Z','2018-02-01T00:00:00.000Z',
                                          '2018-03-01T00:00:00.000Z','2018-04-01T00:00:00.000Z',
                                          '2018-05-01T00:00:00.000Z','2018-06-01T00:00:00.000Z',
                                          '2018-07-01T00:00:00.000Z','2018-08-01T00:00:00.000Z',
                                          '2018-09-01T00:00:00.000Z','2018-10-01T00:00:00.000Z',
                                          '2018-11-01T00:00:00.000Z','2018-12-01T00:00:00.000Z'],
                               
                               end_list=['2014-01-31T00:00:00.000Z','2014-02-28T00:00:00.000Z',
                                        '2014-03-31T00:00:00.000Z','2014-04-30T00:00:00.000Z',
                                        '2014-05-31T00:00:00.000Z','2014-06-30T00:00:00.000Z',
                                        '2014-07-31T00:00:00.000Z','2014-08-31T00:00:00.000Z',
                                        '2014-09-30T00:00:00.000Z','2014-10-31T00:00:00.000Z',
                                        '2014-11-30T00:00:00.000Z','2014-12-31T00:00:00.000Z',
                                        
                                        '2015-01-31T00:00:00.000Z','2015-02-28T00:00:00.000Z',
                                        '2015-03-31T00:00:00.000Z','2015-04-30T00:00:00.000Z',
                                        '2015-05-31T00:00:00.000Z','2015-06-30T00:00:00.000Z',
                                        '2015-07-31T00:00:00.000Z','2015-08-31T00:00:00.000Z',
                                        '2015-09-30T00:00:00.000Z','2015-10-31T00:00:00.000Z',
                                        '2015-11-30T00:00:00.000Z','2015-12-31T00:00:00.000Z',
                                        '2016-01-31T00:00:00.000Z','2016-02-29T00:00:00.000Z',
                                        '2016-03-31T00:00:00.000Z','2016-04-30T00:00:00.000Z',
                                        '2016-05-31T00:00:00.000Z','2016-06-30T00:00:00.000Z',
                                        '2016-07-31T00:00:00.000Z','2016-08-31T00:00:00.000Z',
                                        '2016-09-30T00:00:00.000Z','2016-10-31T00:00:00.000Z',
                                        '2016-11-30T00:00:00.000Z','2016-12-31T00:00:00.000Z',
                                        
                                        '2017-01-31T00:00:00.000Z','2017-02-28T00:00:00.000Z',
                                        '2017-03-31T00:00:00.000Z','2017-04-30T00:00:00.000Z',
                                        '2017-05-31T00:00:00.000Z','2017-06-30T00:00:00.000Z',
                                        '2017-07-31T00:00:00.000Z','2017-08-31T00:00:00.000Z',
                                        '2017-09-30T00:00:00.000Z','2017-10-31T00:00:00.000Z',
                                        '2017-11-30T00:00:00.000Z','2017-12-31T00:00:00.000Z',
                                        
                                        '2018-01-31T00:00:00.000Z','2018-02-28T00:00:00.000Z',
                                        '2018-03-31T00:00:00.000Z','2018-04-30T00:00:00.000Z',
                                        '2018-05-31T00:00:00.000Z','2018-06-30T00:00:00.000Z',
                                        '2018-07-31T00:00:00.000Z','2018-08-31T00:00:00.000Z',
                                        '2018-09-30T00:00:00.000Z','2018-10-31T00:00:00.000Z',
                                        '2018-11-30T00:00:00.000Z','2018-12-31T00:00:00.000Z'],
                                         keyword= "has:geo lang:nl from: 5799162",
                               tweet_per_period=10)
                               
#Convert the Twitter json output to csv  and save files                             
tweet, user = dl.to_dataframe(tweet_list)
geo_info = pd.DataFrame({"datum" : tweet["created_at"], "plaats": tweet["location_geo"]})
data_lijst = geo_info["datum"].tolist()
plaats_lijst = geo_info["plaats"].tolist()
res = [[] for i in range(1,21)]
for i in range(0,len(data_lijst)):
        d = data_lijst[i]
        jaar = d.year - 2010
        maand = d.month
        ip = (maand - 1)//3 + 1
        p = 4*jaar - 15 
        kolom = p + ip - 2
        res[kolom].append(plaats_lijst[i])
        for i in range(0,20):
    res[i].sort()
    loc_lijst = list(set(res[i]))
    extra = [(l,res[i].count(l)) for l in loc_lijst]
    extra.sort(key = lambda x: x[1])
    res[i].extend(extra)
        
g = max(len(res[i]) for i in range(0,20))
for i in range(0,20):  
    laatste = len(res[i])
    v = g - len(res[i])
    for j in range(0,v): 
        res[i].append(" ") 
    res[i].append("FINAL")
    res[i].append(res[i][laatste-1][0].upper())
    
iks = {"periode 1" : res[0],
       "periode 2" : res[1],
       "periode 3" : res[2],
       "periode 4" : res[3],
       "periode 5" : res[4],
       "periode 6" : res[5],
       "periode 7" : res[6],
       "periode 8" : res[7],
       "periode 9" : res[8],
       "periode 10" : res[9],
       "periode 11" : res[10],
       "periode 12" : res[11],
       "periode 13" : res[12],
       "periode 14" : res[13],
       "periode 15" : res[14],
       "periode 16" : res[15],
       "periode 17" : res[16],
       "periode 18" : res[17],
       "periode 19" : res[18],
       "periode 20" : res[19]
      }

    
migration_info = pd.DataFrame(iks) 
    
tweet.to_csv('C:\\Users\\nadeg\\OneDrive\\Documenten\\uitvoerbestanden\\tweet_output_path.csv')
user.to_csv('C:\\Users\\nadeg\\OneDrive\\Documenten\\uitvoerbestanden\\user_output_path.csv')
migration_info.to_csv('C:\\Users\\nadeg\\OneDrive\\Documenten\\uitvoerbestanden\\migration_output_path.csv')

```
