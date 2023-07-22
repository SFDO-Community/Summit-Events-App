// Copyright (c) 2023, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas o 7/22/2023

public with sharing class SummitQuestionWrapper {
    public String questionId { get; set; }
    public String type { get; set; }
    public String question { get; set; }
    public Boolean required { get; set; }
    public List<SelectOption> picklist { get; set; }
    public String help { get; set; }
    public String instructions { get; set; }
    public String assist { get; set; }
    public String defaultValue { get; set; }
    public Integer textLimit { get; set; }
    public String mapTo { get; set; }
    public String lookup { get; set; }
    public String icon { get; set; }
    public String secondaryLinkText { get; set; }
    public String secondaryQuestion { get; set; }
    public String secondaryMapTo { get; set; }
    public String secondaryNoResults { get; set; }
    public String setupError { get; set; }
    public Boolean setupFail { get; set; }
    public String displayStyle { get; set; }
}