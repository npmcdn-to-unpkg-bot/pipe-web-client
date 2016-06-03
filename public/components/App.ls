require! \fs
{concat-map, drop, filter, find, fold, group-by, id, keys, last, map, Obj, obj-to-pairs, 
pairs-to-obj, reject, reverse, Str, sort-by, take, unique,  unique-by, values, zip-with} = require \prelude-ls
{partition-string} = require \prelude-extension
{create-class, create-factory, DOM:{a, button, div, form, h1, h2, img, input, li, ol, option, span, ul, label}}:React = require \react
{find-DOM-node, render} = require \react-dom
require! \react-router
{hash-history} = react-router
Link = create-factory react-router.Link
Route = create-factory react-router.Route
Router = create-factory react-router.Router
Example = create-factory require \./Example.ls

examples =
  * title: 'correlation-matrix'
    description: ""
    languages:
        ls: fs.read-file-sync \public/examples/correlation-matrix.ls, \utf8
        babel: fs.read-file-sync \public/examples/correlation-matrix.js, \utf8
  * title: 'funnel'
    description: ""
    languages:
        ls: fs.read-file-sync \public/examples/funnel.ls, \utf8
        babel: fs.read-file-sync \public/examples/funnel.js, \utf8
  * title: 'radar'
    description: ""
    languages:
        ls: fs.read-file-sync \public/examples/radar.ls, \utf8      
        babel: fs.read-file-sync \public/examples/radar.js, \utf8      
  * title: 'heatmap'
    description: ""
    languages:
        ls: fs.read-file-sync \public/examples/heatmap.ls, \utf8
        babel: fs.read-file-sync \public/examples/heatmap.js, \utf8
  * title: 'histogram'
    description: ""
    languages:
        ls: fs.read-file-sync \public/examples/histogram.ls, \utf8
        babel: fs.read-file-sync \public/examples/histogram.js, \utf8
  * title: 'histogram1'
    description: ""
    languages:
        ls: fs.read-file-sync \public/examples/histogram1.ls, \utf8
        babel: fs.read-file-sync \public/examples/histogram1.js, \utf8
  * title: 'multi-bar-horizontal'
    description: ""
    languages:
        ls: fs.read-file-sync \public/examples/multi-bar-horizontal.ls, \utf8 
        babel: fs.read-file-sync \public/examples/multi-bar-horizontal.js, \utf8 
  * title: 'multi chart'
    description: ""
    languages:
        ls: fs.read-file-sync \public/examples/multi-chart.ls, \utf8 
        babel: fs.read-file-sync \public/examples/multi-chart.js, \utf8 
  * title: \regression
    description: ""
    languages:
        ls: fs.read-file-sync \public/examples/regression.ls, \utf8 
        babel: fs.read-file-sync \public/examples/regression.js, \utf8 
  * title: "scatter"
    description: ""
    languages:
        ls: fs.read-file-sync \public/examples/scatter.ls, \utf8 
        babel: fs.read-file-sync \public/examples/scatter.js, \utf8 
  * title: "scatter1"
    description: ""
    languages:
        ls: fs.read-file-sync \public/examples/scatter1.ls, \utf8 
        babel: fs.read-file-sync \public/examples/scatter1.js, \utf8 
  * title: "stacked-area"
    description: ""
    languages:
        ls: fs.read-file-sync \public/examples/stacked-area.ls, \utf8 
        babel: fs.read-file-sync \public/examples/stacked-area.js, \utf8 
  * title: "table"
    description: ""
    languages:
        ls: fs.read-file-sync \public/examples/table.ls, \utf8 
        babel: fs.read-file-sync \public/examples/table.js, \utf8 
  * title: "timeseries"
    description: ""
    languages:
        ls: fs.read-file-sync \public/examples/timeseries.ls, \utf8 
        babel: fs.read-file-sync \public/examples/timeseries.js, \utf8 
  * title: "timeseries1"
    description: ""
    languages:
        ls: fs.read-file-sync \public/examples/timeseries1.ls, \utf8
        babel: fs.read-file-sync \public/examples/timeseries1.js, \utf8
  * title: "layout"
    description: ""
    languages:
        ls: fs.read-file-sync \public/examples/layout.ls, \utf8 
        babel: fs.read-file-sync \public/examples/layout.js, \utf8 
  ...

App = create-class do

    display-name: \App

    # get-default-props :: () -> Props
    get-default-props: ->
        query: {}

    # render :: () -> ReactElement
    render: -> 
        # APP

        default-snippets-lang = @props.location.query.lang ? \babel

        div class-name: \app,

            div class-name: 'languages',
                [['ls', 'LiveScript'], ['babel', 'Babel']] |> map ([abbr, title]) ~>
                    div do 
                        key: abbr 
                        input type: 'radio', name: 'language-abbr', id: abbr, checked: abbr == default-snippets-lang, on-change: ~>
                            hash-history.replace do 
                                pathname: @props.location.pathname
                                query: {} <<< @props.location.query <<< {lang: abbr}
                                state: @state

                        label html-for: abbr, title

            # EXAMPLES
            div class-name: \examples,
                examples |> map ({title, description, {jsx, ls}:languages}) ~>
                    key = "#{title.to-lower-case!.replace /\s+/g, '_'}"

                    # EXAMPLE
                    Example do 
                        key: key
                        ref: key
                        title: title
                        description: description
                        width: 850
                        style:
                            margin-bottom: 60
                        language-abbr: @state[key] ? default-snippets-lang
                        on-language-abbr-changed: (lang) ~> @set-state "#key": lang
                        languages: languages
                            |> obj-to-pairs
                            |> map ([abbr, initial-content]) ->
                                abbr: abbr
                                title: match abbr
                                    | \ls => \livescript
                                    | \js => \javascript
                                    | _ => abbr
                                initial-content: initial-content
    
    # scroll-to-example :: () -> Void
    scroll-to-example: !->
        example-element = find-DOM-node @refs?[@props.location.query.example]
        if !!example-element
            <~ set-timeout _, 150
            example-element.scroll-into-view!

    # external links
    # component-did-mount :: () -> Void
    component-did-mount: !-> @scroll-to-example!

    # changing the query string manually, or clicking on a different example
    # component-did-update :: Props -> Void
    component-did-update: (prev-props) !-> 
        if prev-props.location.query.example != @props.location.query.example
            @scroll-to-example!

    get-initial-state: -> {}

render do 
    Router do 
        history: react-router.hash-history
        Route path: \/, component: App
    document.get-element-by-id \mount-node