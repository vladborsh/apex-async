# Apex Async

Take control of your asynchronous Apex processes by using apex-async.
The core idea is in composing asynchronous parts of the complex flow into the single chain and run all process from one place. This parts can be branched regarding the success or failure of the previous part.

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## How to

First, one or more classes which represent business logic should implement Queueable interface. Then create AsyncUnit instances from them. You can specify success flow or failure flow for every single unit. Concatenate async units with AsyncProcessor class and execute it. Please notes, if you've not specified failure flow, the processor will call the general on-error action. If general on-error action also haven't specified exception won't be processed.
