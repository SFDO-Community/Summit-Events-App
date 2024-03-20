import { api, LightningElement } from 'lwc';

// Import custom labels
import DFSPI_Complete from '@salesforce/label/c.DFSPI_Complete';
import DFSPI_Current from '@salesforce/label/c.DFSPI_Current';
import DFSPI_Upcoming from '@salesforce/label/c.DFSPI_Upcoming';

export default class DynamicFlowStageProgressIndicator extends LightningElement {
    @api indicatorType;
    @api stepList;
    @api currentStep;
    @api currentStepPercentage;
    
    // Expose the labels to use in the template
    label = {
        DFSPI_Complete,
        DFSPI_Current,
        DFSPI_Upcoming
    };

    showTypeVertical;
    showTypeVertNav;
    showTypeHorizontal;
    showTypePath;
    showTypeBar;
    showTypeRing;

    stepsArray;
    pathProgress;

    stepPercent;
    countTotalSteps;
    countToCurrent;

    progressLabel;
    
    connectedCallback(){
        
        // clean the indicatorType variable of any leading/trailing spaces and convert to lowercase
        let indicatorDirty = this.indicatorType;
        let indicatorClean = indicatorDirty.trim().toLowerCase();
        let considerCurrentStepPercentage = false;

        // set conditions for which indicator type displays
        switch (indicatorClean) {
            case 'vertical':
                this.showTypeVertical = true;
                break;
            case 'vertnav':
                this.showTypeVertNav = true;
                break;
            case 'horizontal':
                this.showTypeHorizontal = true;
                break;
            case 'path':
                this.showTypePath = true;
                break;
            case 'bar':
                this.showTypeBar = true;
                considerCurrentStepPercentage = true;
                break;
            case 'ring':
                this.showTypeRing = true;
                considerCurrentStepPercentage = true;
                break;
            default:
                this.showTypeHorizontal = true;
                break;
        }
        
        // convert stepList from string of comma-separated values to an array
        const stepListArray = this.stepList.split(',');

        let countTotalSteps = stepListArray.length;
        let stepsArrayTemp = [];
        let afterCurrent = false;
        let countToCurrent = 0;
        let currentCount = 0;

        for (let i = 0; i < stepListArray.length; i++) {
            currentCount = i+1;

            let isFinalStep = false;
            if(currentCount == countTotalSteps){
                isFinalStep = true;
            }
            
            let cleanArrayValue = stepListArray[i].trim();
            
            if(afterCurrent == false) {
                
                // this step might be Completed or Current
                if(cleanArrayValue == this.currentStep) {
                    
                    if(isFinalStep == true) {
                        switch (indicatorClean) {
                            case 'vertical':
                                // this is the final step for the vertnav indicator type, but it needs to be display as Current
                                stepsArrayTemp.push({
                                    'label': cleanArrayValue,
                                    'status': 'Complete',
                                    'showCurrent' : false,
                                    'showComplete' : false,
                                    'showFinalComplete' : true,
                                    'showUpcoming' : false,
                                    'finalStep' : true
                                });
                                break;
                            case 'vertnav':
                                // this is the final step for the vertnav indicator type, but it needs to be display as Current
                                stepsArrayTemp.push({
                                    'label': cleanArrayValue,
                                    'status': 'Complete',
                                    'showCurrent' : false,
                                    'showComplete' : false,
                                    'showFinalComplete' : true,
                                    'showUpcoming' : false,
                                    'finalStep' : true
                                });
                                break;
                            default:
                                // this is the current step, but since it is the final one, it is marked as Complete instead
                                stepsArrayTemp.push({
                                    'label': cleanArrayValue,
                                    'status': 'Complete',
                                    'showCurrent' : false,
                                    'showComplete' : true,
                                    'showFinalComplete' : false,
                                    'showUpcoming' : false,
                                    'finalStep' : true
                                });
                                break;
                        }

                        countToCurrent++;
                    }
                    else {

                        // this is the current step, but it is not the final one (or it's the final one for the vertnav indicator type)
                        stepsArrayTemp.push({
                            'label': cleanArrayValue,
                            'status': 'Current',
                            'showCurrent' : true,
                            'showComplete' : false,
                            'showUpcoming' : false,
                            'finalStep' : false
                        });
                        
                        // set afterCurrent to true,
                        // so all subsequent steps
                        // are marked as future
                        afterCurrent = 'true';
                        countToCurrent++;
                    }
                }
                else {
                    
                    // this is a completed step
                    stepsArrayTemp.push({
                        'label': cleanArrayValue,
                        'status': 'Complete',
                        'showCurrent' : false,
                        'showComplete' : true,
                        'showUpcoming' : false,
                        'finalStep' : isFinalStep
                    });
                    countToCurrent++;
                }
            }
            else {
                
                // this is an upcoming step
                stepsArrayTemp.push({
                    'label': cleanArrayValue,
                    'status': 'Upcoming',
                    'showCurrent' : false,
                    'showComplete' : false,
                    'showUpcoming' : true,
                    'finalStep' : false
                });
            }
        }
        
        // this.countToCurrent = countToCurrent;
        // this.countTotalSteps = countTotalSteps;

        // set pathProgress to number of steps unless currentStepPercentage is set
        if(considerCurrentStepPercentage == true) {

            let percentProperty = this.currentStepPercentage;

            if(percentProperty > 0) {
                this.pathProgress = percentProperty;

                this.stepPercent = percentProperty;

                let testPercent = percentProperty;

                // need a label property for the Bar indicator type that shows completion like "45% Complete"
                this.progressLabel = `${percentProperty}% ${this.label.DFSPI_Complete}`;

                // setting dynamic css width value for the Bar and Ring indicator types
                document.documentElement.style.setProperty('--value', percentProperty);
            }

            else {
                this.pathProgress = (((countToCurrent-1)/(countTotalSteps-1)*100));

                // need a label property for the Bar indicator type that shows completion like "45% Complete"
                this.progressLabel = `${this.pathProgress}% ${this.label.DFSPI_Complete}`;

                // setting dynamic css width value for the Bar and Ring indicator types
                document.documentElement.style.setProperty('--value', this.pathProgress);
            }
        }

        // indicator type is not a bar or ring
        else {
            this.pathProgress = (((countToCurrent-1)/(countTotalSteps-1)*100));

            // need a label property for the Horizontal indicator type that shows completion like "45% Complete"
            this.progressLabel = `${this.pathProgress}% ${this.label.DFSPI_Complete}`;
            
            // setting dynamic css width value for the Horizontal indicator type
            document.documentElement.style.setProperty('--value', this.pathProgress);
        }

        // store list of steps to iterate over in the html
        this.stepsArray = stepsArrayTemp;
    }
}