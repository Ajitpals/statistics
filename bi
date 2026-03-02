You can also scroll to the bottom for instructions on how to export this as a downloadable document from Power BI.

📘 Power BI Throughput-Based Forecasting & Gantt Implementation Guide
1️⃣ Data Model Setup
Tables Required
Epic

WorkItemId

Title

Feature

WorkItemId

EpicId

Title

TargetDate

UserStory

WorkItemId

FeatureId

State

ClosedDate

InProgressDate

Title

Relationships

Create the following relationships (Single direction):

Epic[WorkItemId] → Feature[EpicId] (1 to Many)

Feature[WorkItemId] → UserStory[FeatureId] (1 to Many)

Avoid bidirectional filters.

2️⃣ Throughput-Based Forecast Setup

We forecast using:

Remaining Stories ÷ Average Weekly Throughput

Step 1 — Completed T1 Stories (Last 12 Weeks)

Create Measure:

Completed T1 (12w) :=
CALCULATE(
    COUNTROWS(UserStory),
    UserStory[State] = "Closed",
    LEFT(UserStory[Title],3) = "T1:",
    UserStory[ClosedDate] >= TODAY() - 84
)
Step 2 — Average Weekly Throughput
Avg Weekly Throughput :=
DIVIDE(
    [Completed T1 (12w)],
    12
)
Step 3 — Remaining Stories Per Feature
Remaining Stories :=
CALCULATE(
    COUNTROWS(UserStory),
    UserStory[State] <> "Closed"
)
3️⃣ Required Feature Columns (For Microsoft Gantt)

⚠ Microsoft Gantt requires COLUMNS, not measures.

Create these in the Feature table.

Feature Start Date
Feature Start Date =
CALCULATE(
    MIN(UserStory[InProgressDate]),
    FILTER(
        UserStory,
        UserStory[FeatureId] = Feature[WorkItemId]
            && NOT(ISBLANK(UserStory[InProgressDate]))
    )
)
Forecast End Date (Throughput-Based)
Forecast End Date =
VAR Throughput =
    DIVIDE(
        CALCULATE(
            COUNTROWS(UserStory),
            UserStory[State] = "Closed",
            LEFT(UserStory[Title],3) = "T1:",
            UserStory[ClosedDate] >= TODAY() - 84
        ),
        12
    )

VAR Remaining =
    CALCULATE(
        COUNTROWS(UserStory),
        UserStory[State] <> "Closed"
    )

VAR WeeksNeeded =
    DIVIDE(Remaining, Throughput)

RETURN
TODAY() + (WeeksNeeded * 7)
RAG Status Column
RAG Status =
VAR ForecastDate = Feature[Forecast End Date]
VAR TargetDate = Feature[TargetDate]
VAR VarianceDays = DATEDIFF(TargetDate, ForecastDate, DAY)

RETURN
SWITCH(
    TRUE(),
    VarianceDays >= 0, "Green",
    VarianceDays >= -14, "Amber",
    "Red"
)
4️⃣ Microsoft Gantt Visual Setup

Add Microsoft Gantt visual from AppSource.

Map Fields
Gantt Field	Value
Task	Feature[Title]
Parent	Epic[Title]
Start Date	Feature[Feature Start Date]
End Date	Feature[Forecast End Date]
Milestone	Feature[TargetDate]
Legend	Feature[RAG Status]
Colour Configuration

Go to:

Format → Data Colors

Set manually:

Green → #2E7D32

Amber → #ED6C02

Red → #D32F2F

Now bars will automatically change colour based on risk.

5️⃣ Stakeholder Matrix View

Add a Matrix visual.

Rows

Epic[Title]

Feature[Title]

Values

Remaining Stories

Forecast End Date

Target Date

RAG Status

Variance Measure (Optional)
Variance (Days) :=
DATEDIFF(
    SELECTEDVALUE(Feature[TargetDate]),
    SELECTEDVALUE(Feature[Forecast End Date]),
    DAY
)

Apply conditional formatting:

≥ 0 → Green

-1 to -14 → Amber

< -14 → Red

6️⃣ Executive KPI Cards

Create Cards for:

% Green Features
% Green Features :=
DIVIDE(
    CALCULATE(COUNTROWS(Feature), Feature[RAG Status] = "Green"),
    COUNTROWS(Feature)
)
At Risk Count
At Risk Count :=
CALCULATE(
    COUNTROWS(Feature),
    Feature[RAG Status] <> "Green"
)
Average Variance
Avg Variance :=
AVERAGEX(
    Feature,
    DATEDIFF(
        Feature[TargetDate],
        Feature[Forecast End Date],
        DAY
    )
)
7️⃣ Monte Carlo Forecast Enhancement (Advanced)

Instead of using average throughput:

Capture last 12 weeks of actual weekly throughput

Randomly sample those values 1,000 times

Simulate completion durations

Produce:

P50 date (most likely)

P80 date (80% confidence)

P95 date (safe commitment)

Best implemented using:

Power Query (List.Random sampling), or

Python/R script inside Power BI

Monte Carlo allows you to tell stakeholders:

“There is 80% confidence this Feature completes before X date.”

This is significantly more reliable than simple averages.

8️⃣ How to Download This as a Document
Option 1 — Export from Power BI Report

Publish report to Power BI Service

File → Export → PDF

Download and share

Option 2 — Create Formal Documentation File

Copy this guide into Microsoft Word

Save as:

PDF for stakeholders

DOCX for internal documentation

Option 3 — Create a Power BI Documentation Page

Inside your PBIX:

Add a new page called “Methodology”

Insert text boxes

Paste the formulas and logic

Export report as PDF

This ensures governance and auditability.

✅ Final Deliverable Structure

Page 1 — Executive Summary
Page 2 — Gantt (RAG coloured)
Page 3 — Matrix + Variance
Page 4 — Throughput Trend
Page 5 — Monte Carlo Confidence

If you would like, I can next generate:

A properly formatted PDF-ready version

A DOCX documentation file

A Power BI template structure outline

Or a Monte Carlo simulation implementation guide (step-by-step in Power Query)
==================================================

ExtractedValue =
VAR InputText = 'Table'[YourTextColumn]
VAR INC_Pos = SEARCH("INC", InputText, 1, 0)
VAR REQ_Pos = SEARCH("REQ", InputText, 1, 0)
VAR WordStart =
    SWITCH (
        TRUE(),
        INC_Pos > 0, INC_Pos,
        REQ_Pos > 0, REQ_Pos,
        0
    )
VAR Extracted =
    IF (
        WordStart > 0,
        TRIM (
            MID (
                InputText,
                WordStart,
                FIND ( " ", InputText & " ", WordStart, 1 ) - WordStart
            )
        )
    )
RETURN Extracted




Creating a Fixed 5-Year Feature Closure Cost Graph in Power BI
Your Data Setup
You have:

Multiple features from Azure DevOps
FTE (custom column with FTE values)
Saving (savings amount)
X (date column - when features close)
Status (includes "Closed" when features are completed)
Cost calculation: (FTE * 89000 + Saving) * 5

Step 1: Create the Cost Calculated Column

Go to Data view in Power BI
Select your table and click New Column
Create the cost column:
DAXFeature Cost = ([FTE] * 89000 + [Saving]) * 5


Step 2: Create Measures for Closed Features
Measure 1: Closed Features Cost
DAXClosed Features Cost = 
CALCULATE(
    SUM('YourTable'[Feature Cost]),
    'YourTable'[Status] = "Closed"
)
Measure 2: Cumulative Closed Cost (Optional - for running total)
DAXCumulative Closed Cost = 
VAR CurrentDate = MAX('YourTable'[X])
RETURN
CALCULATE(
    SUM('YourTable'[Feature Cost]),
    'YourTable'[Status] = "Closed",
    'YourTable'[X] <= CurrentDate,
    ALL('YourTable'[X])
)
Step 3: Create the Visualization

Select Visual: Choose Line Chart from Visualizations pane
Configure Fields:

X-axis: Drag your X (date column)
Y-axis: Drag [Closed Features Cost] or [Cumulative Closed Cost]
Legend: Drag Feature (if you want individual feature lines)



Step 4: Set Fixed 5-Year Range
Method A: Visual Filter (Recommended)

In Filters pane, drag X (date column) to Filters on this visual
Select Advanced filtering
Choose is between
Set your 5-year range:

From: 1/1/2024 (or your start date)
To: 12/31/2028 (or your end date)


Click Apply filter

Method B: Format X-Axis

Select your chart
Go to Format pane → X-axis
Set Range to Manual
Minimum: 1/1/2024
Maximum: 12/31/2028

Step 5: Format the Chart

Chart Title:

Go to Format → General → Title
Enter: "Feature Closure Costs - 5 Year Timeline"


Y-Axis Formatting:

Format → Y-axis
Set Display units to appropriate level (K, M)
Add $ prefix if needed


X-Axis Formatting:

Format → X-axis
Set appropriate date format (Monthly, Quarterly, Yearly)


Data Colors:

Format → Visual → Colors
Adjust colors for better visibility



Step 6: Handle Multiple Features
Option A: Individual Feature Lines

Keep Feature in Legend field
This shows separate line for each feature

Option B: Aggregated View

Remove Feature from Legend
Shows total cost across all features
Use this if you have many features and individual lines are cluttered

Option C: Top N Features Filter

Add Feature to Filters on this visual
Change filter type to Top N
Show top 10 (or desired number) by Feature Cost

Final Result
You'll have a line graph showing:

X-axis: Fixed 5-year timeline (regardless of actual data range)
Y-axis: Cost of features as they transition to "Closed" status
Timeline: Constrained to exactly 5 years
Features: Either individual lines or aggregated totals

The graph will maintain the 5-year scale even if features close only in certain periods, giving you a consistent view of feature closure costs over time.RetryClaude does not have the ability to run the code it generates yet.Ai have feature created date , add 5 year to this dateEditCreating a Dynamic 5-Year Feature Graph Based on Feature Creation Date
Your Enhanced Data Setup
You have:

Multiple features from Azure DevOps
FTE (custom column with FTE values)
Saving (savings amount)
Feature Created Date (when feature was created)
X (date column - when features close)
Status (includes "Closed" when features are completed)
Cost calculation: (FTE * 89000 + Saving) * 5

Step 1: Create Calculated Columns
1.1: Feature Cost Column
DAXFeature Cost = ([FTE] * 89000 + [Saving]) * 5
1.2: Feature End Date (Created Date + 5 Years)
DAXFeature End Date = DATE(YEAR([Feature Created Date]) + 5, MONTH([Feature Created Date]), DAY([Feature Created Date]))
1.3: Feature Timeline (Optional - for filtering)
DAXIs Within 5 Years = 
IF(
    [X] >= [Feature Created Date] && [X] <= [Feature End Date],
    "Yes",
    "No"
)
Step 2: Create Measures
2.1: Closed Features Within Timeline
DAXClosed Features Cost = 
CALCULATE(
    SUM('YourTable'[Feature Cost]),
    'YourTable'[Status] = "Closed",
    'YourTable'[X] >= 'YourTable'[Feature Created Date],
    'YourTable'[X] <= 'YourTable'[Feature End Date]
)
2.2: Cumulative Closed Cost Within 5-Year Window
DAXCumulative Closed Cost = 
VAR CurrentDate = MAX('YourTable'[X])
RETURN
CALCULATE(
    SUM('YourTable'[Feature Cost]),
    'YourTable'[Status] = "Closed",
    'YourTable'[X] <= CurrentDate,
    'YourTable'[X] >= 'YourTable'[Feature Created Date],
    'YourTable'[X] <= 'YourTable'[Feature End Date],
    ALL('YourTable'[X])
)
2.3: Days from Feature Creation (for relative timeline)
DAXDays from Creation = 
DATEDIFF(
    MIN('YourTable'[Feature Created Date]),
    MAX('YourTable'[X]),
    DAY
)
Step 3: Create the Visualization
Option A: Individual Feature Timelines

Visual: Line Chart
Fields:

X-axis: X (closure date)
Y-axis: [Closed Features Cost]
Legend: Feature (shows individual feature lines)



Option B: Relative Timeline (Days from Creation)

Visual: Line Chart
Fields:

X-axis: [Days from Creation]
Y-axis: [Closed Features Cost]
Legend: Feature



Step 4: Set Dynamic Filters
4.1: Filter to 5-Year Window Only

Add Is Within 5 Years to Filters on this visual
Select only "Yes"

4.2: Alternative: Use Date Filter

Add X (date) to Filters on this visual
Select Advanced filtering → Custom filter
Create custom filter:
X is greater than or equal to Feature Created Date
AND
X is less than or equal to Feature End Date


Step 5: Create Master Timeline View
5.1: Normalize All Features to Start from Day 0
Create this calculated column:
DAXNormalized Timeline = DATEDIFF([Feature Created Date], [X], DAY)
5.2: Create Visualization

Visual: Line Chart
X-axis: Normalized Timeline (0 to 1825 days = 5 years)
Y-axis: [Closed Features Cost]
Legend: Feature

Step 6: Format the Chart
6.1: For Actual Date Timeline

X-axis: Standard date formatting
Title: "Feature Closure Costs (5-Year Lifecycle)"

6.2: For Normalized Timeline

X-axis:

Minimum: 0
Maximum: 1825 (5 years × 365 days)
Title: "Days from Feature Creation"


Chart Title: "Feature Lifecycle - Closure Costs (Day 0 to 1825)"

Step 7: Advanced Options
7.1: Show Only Active 5-Year Windows
DAXActive Features Only = 
CALCULATE(
    [Closed Features Cost],
    FILTER(
        'YourTable',
        TODAY() >= [Feature Created Date] && 
        TODAY() <= [Feature End Date]
    )
)
7.2: Feature Lifecycle Status
DAXLifecycle Status = 
SWITCH(
    TRUE(),
    [X] < [Feature Created Date], "Not Started",
    [X] > [Feature End Date], "Beyond Lifecycle", 
    [Status] = "Closed", "Closed",
    "Active"
)
Final Result
You'll have a dynamic graph where:

Each feature has its own 5-year timeline starting from its creation date
Features close within their respective 5-year windows
You can view either individual feature lifecycles or normalized timelines
The graph automatically adjusts based on when each feature was created
