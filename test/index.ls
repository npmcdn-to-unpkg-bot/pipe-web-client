# mock api
require! \nock

pipe-document = 
    _id: \568b5a1c3d29e34e06a8dbcc
    queryId: \pyTpkXM
    parentId: \px7y8pq
    branchId: \psLxTYL
    treeId: \psLxTYL
    dataSourceCue: 
        queryType: \mongodb
        connectionKind: \pre-configured
        complete: true
        connectionName: \test-connection
        database: \test-db
        collection: \test-collection
    queryTitle: "Test query"
    transpilation: 
        query: \livescript
        transformation: \livescript
        presentation: \livescript
    query: "$limit 1"
    transformation: "id"
    presentation: "json"
    tags: []
    clientExternalLibs: []
    parameters: ""
    ui: 
        editor: 
            width: 550
        queryEditor: 
            height: 416
        transformationEditor: 
            height: 451
        presentationEditor: 
            height: 334
    user: null
    creationTime: 1451973148927
    status: true

branch = 
    branchId: \psLxTYL
    latestQuery: 
        branchId: \psLxTYL
        queryId: \pyTpkXM
        queryTitle: 'MA Subscriber Info'
        dataSourceCue: 
            queryType: \mssql
            connectionKind: \pre-configured
            complete: true,
            connectionName: \mobitrans
            database: \
        tags: [],
        user: null,
        creationTime: 1451973148927
    snapshot: \/public/snapshots/psLxTYL.png

default-document = 
    query: """
        $sort _id: -1 
        $limit 20
    """
    transformation: "id"
    presentation: "json"
    parameters: ""

all-tags = <[multi mongo dashboard]>

result-with-meta = 
    execute-start-time: Date.now!
    result: 
        * _id: ""
          ip: \127.0.0.1
          country: \-
        ...

nock \http://pipe.com/apis/

    .get \/queries/pyTpkXM
    .reply 200, pipe-document

    .get \/branches/psLxTYL
    .reply 200, [branch]

    .get \/queries/pyTpkXM
    .reply 200, pipe-document

    .post \/defaultDocument, ([data-source-cue, transpilation-langauge]?) ->
        data-source-cue `is-equal-to-object` pipe-document.data-source-cue and 
        transpilation-langauge == pipe-document.transpilation.query
    .reply 200, default-document

    .get \/tags
    .reply 200, all-tags

    .post \/execute, ({data-source-cue, query, transpilation-language}) ->
        data-source-cue `is-equal-to-object` pipe-document.data-source-cue and
        query == pipe-document.query and 
        transpilation-language == pipe-document.transpilation.query
    .reply 200, result-with-meta

    .get \/queries/pyTpkXM
    .reply 200, pipe-document

    .get \/branches/psLxTYL
    .reply 200, [branch]

    .get \/queries/pyTpkXM
    .reply 200, pipe-document

    .post \/execute, ({data-source-cue, query, transpilation-language}) ->
        data-source-cue `is-equal-to-object` pipe-document.data-source-cue and
        query == pipe-document.query and 
        transpilation-language == pipe-document.transpilation.query
    .reply 200, result-with-meta

# setup jsdom, mock browser environment
require! \jsdom
global <<< 
    document: jsdom.jsdom '<!doctype html><html><body></body></html>'
    navigator: user-agent: \JSDOM
    window: document.parent-window

Promise = require \bluebird
{is-equal-to-object} = require \prelude-extension
{load-query, load-latest-query, load-default-document, get-all-tags, execute,
compile-query, compile-latest-query} = (require \../index.ls) end-point: \http://pipe.com

describe \pipe-web-client, ->

    # assert-object-equality :: Document -> Document -> p String?
    assert-object-equality = (a, b) ->
        if a `is-equal-to-object` b
            Promise.resolve null 
        else 
            Promise.reject "document mismatch"

    specify \load-query, ->
        remote-document <- load-query \pyTpkXM .then
        remote-document `assert-object-equality` pipe-document

    specify \load-latest-query, ->
        remote-document <- load-latest-query \psLxTYL .then
        remote-document `assert-object-equality` pipe-document

    specify \load-default-document, ->
        remote-document <- load-default-document pipe-document.data-source-cue, pipe-document.transpilation.query .then
        remote-document `assert-object-equality` default-document

    specify \get-all-tags, ->
        tags <- get-all-tags! .then
        tags `assert-object-equality` all-tags

    specify \execute, ->
        {data-source-cue, query, transpilation} = pipe-document
        result <- execute data-source-cue, query, transpilation.query, {}, false, '', {} .then
        result `assert-object-equality` result-with-meta 

    specify \compile-query, ->
        view = document.create-element \div
        {execute, transformation-function, presentation-function} <- compile-query \pyTpkXM .then
        result <- execute false, {} .then
        <- (assert-object-equality result, result-with-meta.result).then
        <- (assert-object-equality result, (transformation-function result, {})).then
        presentation-function view, result, {}
        if (view.innerHTML.index-of \<pre>) == 0 then Promise.resolve null else Promise.reject \invalid-dom
