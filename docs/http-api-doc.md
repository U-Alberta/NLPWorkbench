HTTP API References
======
Refer to the guides of [requests](https://docs.python-requests.org/en/latest/) or [HTTPie](https://httpie.io) to learn more about how to make requests to HTTP APIs.

By default, the API endpoints omit the host part and the prefix `/api`. For example, if NLPWorkbench is running at `http://localhost:12345` and we want to make a request to `/collection/<collection_name>`, the request should be made to `http://localhost:12345/api/collection/<collection_name>`.

Names in brackets, such as `<collection_name>`, represent variables. They should be replaced with actual values. For example, when making a request to `/api/collection/<collection_name>` to create a collection called `my_collection`, replace `<collection_name>` with `my_collection`.

## General
### API status
`GET /`

Returns `It's working!` if `api` service is running.

## Collection
### Create a collection
`PUT /collection/<collection_name>`

Request body:
```json
{
    "description": "Optional. Some description"
}
```

Creates a new collection with name `<collection_name>` and description.

Returns collection name and code 201.

### List all collections
`GET /collection`

If `detailed` is in URL parameters, returns a detailed list of all collections.
```json
[
    {
        "name": "collection1",
        "description": "Some description",
        "creation_date": 1691578383,
        "docs": 123
    }
]
```

If `detailed` is not in URL parameters, returns a list of collection names.
```json
[
    "collection1",
    "collection2"
]
```
### Upload multiple documents
`POST /collection/<collection>/uploadfile`

Upload a file as multipart/form-data. The file should be named `file`.

The file must be a JSON document in UTF-8 encoding in the following format:
```json
{
    "doc": [
        {"text": "some text"}, 
        {"text": "some text"}, 
        {"text": "some text"}, 
        {"text": "some text"}
    ]
}
```

### Delete a collection
`DELETE /collection/<collection_name>`

### Run Elasticsearch query on a collection
`POST /collection/<collection_name>/preview`

Body:
```json
{
    "skip": 0,
    "size": 10,
    "query": {
        "match": {
            "text": "some text"
        }
    }
}
```

Returns
```json
{
    "total": 123,
    "hits": [
        {
            "id": "doc_id",
            "title": "doc title",
            "text": "doc text",
            "url": "doc url"
        }
    ]
}
```

## Document
### Get a document
`GET /collection/<collectoin_name>/doc/<doc_id>`

URL parameters:
* `tokenize`: defaults to False. If true, the returned document contains the field `sentences`.
* `skip_text`: defaults to False. If true, the text will not be returned.

Returns a JSON document
```json
{
    "title": "Document Title",
    "author": ["Author1", "Author2"],
    "text": "Raw text of the document",
    "url": "http://where-the-document-is-from",
    "id": "unique-identifier-of-the-doc",
    "sentences": [
        ["sent1-token1", "sent1-token2"],
        ["sent2-token1", "sent2-token2"],
    ]
}
```

Returns status `401` if collection name or document id is invalid.

Returns status `404` if collection or document does not exist.

### Get a random document
`GET /collection/<collection_name>/doc/_random`

Returns a random document in collection `collection_name`. See [here](#get-a-document) for the return format.
### Import from URL
`POST /<collection_name>/doc/_import_from_url`

Request body:
```json
{
    "url": "<URL>"
}
```
Downloads the webpage from `<URL>`, parse it using the `newspaper-3k` library, and adds the parsed document into collection `collection_name`.

Returns the imported document. See [here](#get-a-document) for the return format.

Returns 400 if there's an error downloading or parsing the document.

## NLP Tools
### Named entity recognition
`GET /<collection_name>/doc/<doc_id>/ner`

Returns an JSON array. Each element is a sentence.
```json
[
    [{"text": "Token1"}, {...}, {...}],
    [{"text": "Token1"}, {...}, {...}],
]
```

Each sentence is a JSON array where the element can be a regular text token, an entity mention, or a coreference.

A text mention is not an entity.
```json
{"text": "Token1"}
```

An entity mention represents a named entity:
```json
{
    "tokens": ["World", "Health", "Organization"],
    "type": "GPE",
    "sent_idx": 5,
    "token_idx": 6
}
```

A coreference represents a pronoun:
```json
{
    "tokens": ["this", "organization"],
    "type": "GPE",
    "entity": {
        "tokens": ["World", "Health", "Organization"],
        "type": "GPE",
        "sent_idx": 5,
        "token_idx": 6
    }
}
```

### Entity Linking
`GET /<collection_name>/doc/<doc_id>/link/<sent_idx>/<mention_idx>`

`<sent_idx>` and `<mention_idx>` refers to the `sent_idx` and `token_idx` returned in the [NER API](#named-entity-recognition).

Returns an array of candidates
```json
[
    {
        "entity_id": "Q1234",
        "score": 12.84,
        "names": ["WHO", "World Health Organization", "OMS", "世界卫生组织"]
    },
    ......
]
```

### Semantic Parse
`GET /<collection>/doc/<doc_id>/semantic`

Returns an array of AMR graphs, where each element corresponds to a sentence.
```json
[
    {
        "sentence": "Hello world",
        "nodes": [...],
        "edges": [...]
    },
    ....
]
```

Each node is either a variable `{"name": "z1", "concept": "buy"}` or a constant `{"name": "c1", "value": "WHO"}`.

Each edge is a JSON object
```json
{
    "var1": "z0",
    "var2": "z1",
    "relationship": "OP0"
}
```
### Person relation extraction
`GET /<collection>/doc/<doc_id>/person_relation`

Returns an array:
```json
[
    {
        "sent": "The original sentence",
        "rel_text": "The extracted relation"
    }
]
```

### Sentiment Analysis
`GET /<collection>/doc/<doc_id>/sentiment`

Returns `{"polarity_compound": 0.5}`

> positive sentiment: compound score >= 0.05
> neutral sentiment: (compound score > -0.05) and (compound score < 0.05)
> negative sentiment: compound score <= -0.05

### Relation Extraction
`GET /<collection>/doc/<doc_id>/relation`

Returns an array of tuples
```
[
    [subject, object, relation, [sentence]]
]
```

### Classify
`GET /<collection>/doc/<doc_id>/classify`

Runs all classifiers defined on the collection `<collection>`.

Returns
```json
{
    "multiclass_prediction": ["class1", "class2"],
    "another_classifier": ["class1", "class2"],
    "the_third_classifier": ["class1", "class2"],
}
```

## Entity
### Get entity attributes
`GET /entity/<entity_id>/attributes`

Returns an array of attributes of the entity `entity_id`.
```json
[
    {"attribute": "location", "value": "Toronto"},
    {"attribute": "country", "value": "Canada"},
]
```

### Get entity description
`GET /entity/<entity_id>/description`

The description starts with either (Wikidata) or (Wikipedia), indicating its source.

Returns
```json
{
    "entity_id": "Q123",
    "description": "(Wikidata) specialized agency of the United Nations that is concerned with international public health"
}
```