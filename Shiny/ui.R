#ui.R
require(shiny)
require(shinydashboard)

dashboardPage(skin = "yellow", 
              dashboardHeader(title = "2016 Election"
              ),
              dashboardSidebar(
                sidebarMenu(
                  menuItem("Uninsured vs Poverty", tabName = "scatter", icon = icon("dashboard")),
                  menuItem("Median Incomes", tabName = "barchart", icon = icon("dashboard"))
                )
              ),
              dashboardBody(    
                tabItems(
        
                  # Begin Scatterplot content.
                  tabItem(tabName = "scatter", p(strong("Click Generate Scatter Plot to output the graph. You can click and drag over certain data points in order to drill down on them for more info.")), hr(),
                                     actionButton(inputId= "click3", label ="Generate Scatter Plot"),
                                     hr(), # Add space after button.
                                     plotOutput("plot3", height=750,
                                                click = "plot_click",
                                                dblclick = "plot_dblclick",
                                                hover = "plot_hover",
                                                brush = "plot_brush"),
                                     plotOutput("plotZ")
                            
                  ),
                  # End Scatterplot tab content.
                  
                  # Begin Bar Charts tab content.
                  tabItem(tabName = "barchart", p(strong("Click Generate Bar Chart to output the graph. You can adjust these sliders in order to change what is considered a Landslide Victory for either candidate.", "Unlike the Tableau visualizations, there are only four victory margins here: Trump Landslide Victory, Trump Victory, Hillary Landslide Victory, Hillary Victory.")), "Note: District of Columbia will always appear as a landslide victory due to rounding and Hillary's overwhelming lead.", hr(),
                                     sliderInput("TVM1", "Select Cutoff for Trump Landslide Victory:", 
                                                 min = .5, max = 1,  value = .6),
                                     sliderInput("HVM1", "Select Cutoff for Hillary Landslide Victory:", 
                                                 min = .5, max = 1,  value = .6),
                                     actionButton(inputId= "click5", label ="Generate Bar Chart"),
                                     hr(), # Add space after button.
                                     plotOutput("plot5", height=1000, width=1000)
                            
                  )
                  # End Bar Charts tab content.
                )
              )
)

