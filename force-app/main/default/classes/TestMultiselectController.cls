/**
University of St. Thomas
@company : Copyright ? 2016, Enrollment Rx, LLC
All rights reserved.
Redistribution and use in source form, with or without modification, are prohibited without the express written consent of Enrollment Rx, LLC.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
@website : http://www.enrollmentrx.com/
@author EnrollmentRx
@version 1.0
@date@2/15/2017
@description test class of TestMultiselectController
*/

/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class TestMultiselectController {
    static testMethod void myUnitTest() {
        Test.startTest();
        MultiselectController multiSelect = new MultiselectController();
        multiSelect.leftOptions = new List<SelectOption>();
        multiSelect.rightOptions = new List<SelectOption>();
        multiSelect.leftOptions.add(new SelectOption('US', 'US'));
        multiSelect.leftOptions.add(new SelectOption('CANADA', 'Canada'));
        multiSelect.rightOptions.add(new SelectOption('MEXICO', 'Mexico'));
        multiSelect.leftOptionsHidden = 'US&CANADA';
        multiSelect.rightOptionsHidden = 'Mexico';
        Test.stopTest();
    }
}