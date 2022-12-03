import random

from utils import es_request

from ner import run_ner, resolve_coreferences, EntityMention
from linker import run_linker


def update_news_index():
    query = {
        "script": {
            "source": "ctx._source.id = ctx._id",
            "lang": "painless"
        },
        "query": {
            "match_all": {}
        }
    }
    r = es_request("POST", "/bloomberg-reuters-v1/_update_by_query?refresh=true&timeout=10m&conflicts=proceed", json=query)
    print(r.json())

if __name__ == '__main__':
    def main():
        title = "Timeline: Google shutters Chinese site, moves to Hong Kong"
        content = '''SHANGHAI  (Reuters) - Google Inc closed its China-based search service on Monday and began redirecting Web searchers to an uncensored site in Hong Kong, drawing harsh comments from Beijing that raised doubts about the company's future in the world's largest Internet market. 

    Following are some key developments in Google's bumpy foray into China: 2000 - Google develops Chinese-language interface for its Google.com website. 2002 - Google.com becomes temporarily unavailable to Chinese users, with interference from domestic competition suspected. July 2005 - Google hires ex-Microsoft executive Lee Kai Fu as head of Google China. Microsoft sues Google over the move, claiming Lee will inevitably disclose propriety information to Google. The two rivals reach a settlement on the suit over Lee in December. Jan 2006 - Google rolls out Google.cn, its China-based search page that, in accordance with Chinese rules, censors search results. Google says it made the trade-off to "make meaningful and positive contributions" to development in China while abiding by the country's strict censorship laws. Aug 2008 - Google launches free music downloads for users in China to better compete with market leader Baidu Inc. March 2009 - China blocks access to Google's YouTube video site. June 2009 - A Chinese official accuses Google of spreading obscene content over the Internet. The comments come a day after Google.com, Gmail and other Google online services became inaccessible to many users in China. Sept 2009 - Lee resigns as Google China head to start his own company. Google appoints sales chief John Liu to take over Lee's business and operational responsibilities. Oct 2009 - A group of Chinese authors accuses Google of violating copyrights with its digital library, with many threatening to sue. Jan 2010 - Google announces it is no longer willing to censor searches in China and may pull out of the country. Jan 2010 - Google postpones launch of two Android phones in China. Feb 2010 - The New York Times reports the hacking attacks on Google had been traced to two schools in China, citing people familiar with the investigation. The schools deny involvement. March 22, 2010 - Google announces it will move its mainland Chinese-language portal and begin rerouting searches to its Hong Kong-based site.'''
        paragraph = run_ner(title, content)
        paragraph = resolve_coreferences(paragraph)
        entities = [x for x in paragraph[-1] if isinstance(x, EntityMention)]
        candidates = run_linker(paragraph, entities[-1])
        for c in candidates:
            print(c)
    
    main()
