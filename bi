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
