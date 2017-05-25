# server.R
require(ggplot2)
require(dplyr)
require(shiny)
require(shinydashboard)
require(data.world)
require(readr)
require(DT)
library(plotly)
library(httr)

set_config(config(ssl_verifypeer = 0L))

dfs <- data.frame(query(
  data.world(propsfile = "www/.data.world"),
  dataset="vcjaladi/2016-elections-data", type="sql",
  query="select E.*, I.Median_Income, P.Number_Below_PovertyLine, R.White_Population
  from `1ElectionsData.csv/1ElectionsData` E
  
  left join `acs-2015-5-e-income-medians.csv/acs-2015-5-e-income-medians` I 
  on (E.State = I.AreaName)
  
  left join `acs-2015-5-e-poverty-populationinpoverty.csv/acs-2015-5-e-poverty-populationinpoverty` P 
  on (E.State = P.AreaName)
  
  left join `acs-2015-5-e-race-whitepopulation.csv/acs-2015-5-e-race-whitepopulation` R 
  on (E.State = R.AreaName)
  
  order by E.State"
))

swing_states <- c("Colorado","Florida","Iowa", "Michigan", "Minnesota", "Nevada", "New Hampshire", "North Carolina", "Ohio", "Pennsylvania", "Virginia", "Wisconsin")

shinyServer(function(input, output) { 
  
  # These widgets are for the bar chart tab.
  TVM <- reactive({input$TVM1})
  HVM <- reactive({input$HVM1})
  
  # Begin Scatterplot Tab ------------------------------------------------------------------ 
  
  # Parameterization 
  df_sp <- eventReactive(input$click3, {
    
    dfs %>% dplyr::mutate(
      poverty_ratio = (Number_Below_PovertyLine / Total.Population))
    
  })
  
  # # output the plot
  output$plot3 <- renderPlot({
    ggplot(df_sp()) +
      theme(axis.text.x=element_text(size=16, vjust=0.5)) +
      theme(axis.text.y=element_text(size=16, hjust=0.5)) +
      geom_point(aes(x=Uninsured, y=dem16_frac, color=poverty_ratio, size=poverty_ratio)) +
      geom_smooth(aes(x=Uninsured, y=dem16_frac)) +
      labs(title="Percentage of Democratic Voters vs. Percentage Uninsured", y="Democratic Voters (%)", x="Uninsured (%)")+ 
      scale_color_gradient(low="yellow", high="red")
  })
  
  output$plotZ <- renderPlot({
    brush = brushOpts(id="plot_brush", delayType = "throttle", delay = 30)
    bdf=brushedPoints(df_sp(), input$plot_brush)
    if( !is.null(input$plot_brush) ) {
      df_sp() %>% dplyr::filter(State %in% bdf[, "State"]) %>%
        ggplot() + geom_col(aes(x=State, y=Uninsured, fill=poverty_ratio, size=4)) + guides(size=FALSE) + 
        scale_fill_gradient(low="yellow",high="red")
    }
  })
  
  # End Scatterplot Tab ___________________________________________________________   
  
  
  
  
  # Begin Barchart Tab ------------------------------------------------------------------ 
  
  # Parameterization 
  df_bc <- eventReactive(input$click5, {
    
    dfs %>% dplyr::mutate(
      victory_margin = if_else(rep16_frac - dem16_frac > (TVM() - .5), "Trump Landslide Victory", 
                               (if_else(rep16_frac - dem16_frac > 0, "Trump Victory",
                                        (if_else(rep16_frac - dem16_frac < -(HVM() - .5), "Hillary Landslide Victory", "Hillary Victory"))
                               ))))
                               
                            
  })
  
  # # output the plot
  output$plot5 <- renderPlot({
    ggplot(df_bc()) +
      theme(axis.text.x=element_text(size=16, vjust=0.5)) +
      theme(axis.text.y=element_text(size=16, hjust=0.5)) +
      geom_col(aes(x=State, y=Median_Income, fill=victory_margin)) +
      geom_text(aes(x=State, y=Median_Income, label=Median_Income, hjust=-0.25)) +
      geom_hline(aes(yintercept= mean(Median_Income))) +
      labs(title="Medium Income in States by Victor", y="Medium Income (Thousands USD)", x="State") +
      coord_flip() + 
      scale_fill_brewer(palette="Set2")
    
  })
  
  
  # End Barchart Tab ___________________________________________________________
  
  
  # End ShinyServer
})