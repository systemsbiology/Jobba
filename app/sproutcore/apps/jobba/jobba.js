// ==========================================================================
// Project:   Jobba
// Copyright: @2011 My Company, Inc.
// ==========================================================================
/*globals Jobba */

Jobba = SC.Application.create({
  store: SC.Store.create().from('BulkApi.BulkDataSource')
});

// Model

Jobba.Job = SC.Record.extend({
  primaryKey: 'id',

  childRecordNamespace: Jobba,

  title: SC.Record.attr(String),
  details: SC.Record.attr(String),
  currentStep: SC.Record.attr(String, { key: 'current_step' }),
  steps: SC.Record.toMany('Jobba.Step', { nested: true }),

  completeStep: function() {
    var currentStep,
        steps,
        stepNames,
        currentIndex,
        nextStep;

    currentStep = this.get('currentStep');
    steps = this.get('steps');

    stepNames = steps.mapProperty('name');

    currentIndex = stepNames.indexOf(currentStep);
    if(currentIndex < stepNames.length) {
      nextStep = stepNames.objectAt(currentIndex + 1);
      this.set('currentStep', nextStep);

      // Assume a step is not actionable until the server says otherwise
      //this.set('actionable', false);
    }
  }
});
Jobba.Job.resourceName = "job";

Jobba.Step = SC.Record.extend({
  primaryKey: 'id',

  name: SC.Record.attr(String),
  description: SC.Record.attr(String),
  actionable: SC.Record.attr(Boolean, {defaultValue: NO})
});


Jobba.Job.FIXTURES = [
  { "id": "1",
    "title": "Bob",
    "details": "16 yeast samples",
    "currentStep": "Hybridized",
    "steps": [
     {"name": "Submitted", "description":"Waiting for SLIMarray hybridization", "actionable":false},
     {"name": "Hybridized", "description":"Waiting for raw data to go into SLIMarray", "actionable":false},
     {"name": "Extracted", "description":"Prepare data, notify user", "actionable":true},
     {"name": "Sliced", "description":"", "actionable":true},
     {"name": "Diced", "description":"", "actionable":true},
     {"name": "Completed", "description":"User has been notified", "actionable":false}
    ]
  },
  { "id": "2",
    "title": "Jim",
    "details": "8 yeast samples",
    "currentStep": "Extracted",
    "steps": [
     {"name": "Submitted", "description":"Waiting for SLIMarray hybridization", "actionable":false},
     {"name": "Hybridized", "description":"Waiting for raw data to go into SLIMarray", "actionable":false},
     {"name": "Extracted", "description":"Prepare data, notify user", "actionable":true},
     {"name": "Completed", "description":"User has been notified", "actionable":false}
    ]
  },
  { "id": "3",
    "title": "Joe",
    "details": "24 yeast samples",
    "currentStep": "Submitted",
    "steps": [
     {"name": "Submitted", "description":"Waiting for SLIMarray hybridization", "actionable":false},
     {"name": "Hybridized", "description":"Waiting for raw data to go into SLIMarray", "actionable":false},
     {"name": "Extracted", "description":"Prepare data, notify user", "actionable":true},
     {"name": "Completed", "description":"User has been notified", "actionable":false}
    ]
  }
];

// Controller

Jobba.jobListController = SC.ArrayController.create({
  content: []
});

// Views

Jobba.JobsCollectionView = SC.TemplateCollectionView.extend({
});

Jobba.StepsCollectionView = SC.TemplateCollectionView.extend({
  contentBinding: ".parentView.content.steps",

  itemView: SC.TemplateView.extend({
    nameBinding: '.content.name',
    descriptionBinding: '.content.description',
    jobBinding: '.parentView.parentView.content',
    currentStepBinding: '.parentView.parentView.content.currentStep',
    actionableBinding: '.content.actionable',

    isCurrentStep: function() {
      var name = this.get('name');
      var currentStep = this.get('currentStep');

      return name === currentStep;
    }.property('currentStep').cacheable(),

    isActionable: function() {
      var isCurrentStep = this.get('isCurrentStep');
      var actionable = this.get('actionable');

      return isCurrentStep && actionable;
    }.property('actionable', 'isCurrentStep').cacheable(),

    completeStep: function() {
      var job = this.get('job');

      // FIXME: views shouldn't directly access models, right?
      job.completeStep();
    }
  })
});

// Startup

SC.ready(function() {
  Jobba.mainPane = SC.TemplatePane.append({
    layerId: 'jobba',
    templateName: 'jobba'
  });

  var jobs = Jobba.store.find(Jobba.Job);
  Jobba.jobListController.set('content', jobs);
});

