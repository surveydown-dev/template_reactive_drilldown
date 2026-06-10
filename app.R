# Package setup ---------------------------------------------------------------

# Install required packages:
# install.packages("pak")
# pak::pak(c(
#   'surveydown-dev/surveydown', # Development version from GitHub
#   'tidyverse'
# ))

# Load packages
library(surveydown)
library(tidyverse)

# Database setup --------------------------------------------------------------
#
# Details at: https://surveydown.org/docs/storing-data
#
# surveydown stores data on any PostgreSQL database. We recommend
# https://supabase.com/ for a free and easy to use service.
#
# Once you have your database ready, run the following function to store your
# database configuration parameters in a local .env file:
#
# sd_db_config()
#
# Once your parameters are stored, you are ready to connect to your database.
# This template runs in preview mode (set via `mode: preview` in survey.qmd),
# which saves responses locally instead of to a database. To collect real
# responses, run sd_db_config() to store your database credentials, then
# change `mode` to `database` in the survey.qmd YAML header.

db <- sd_db_connect()

# Set up car options data frame

cars <- mpg |>
  distinct(make = manufacturer, model) |>
  mutate(
    make = str_to_title(make),
    model = str_to_title(model)
  )

# UI setup --------------------------------------------------------------------

ui <- sd_ui()

# Server setup ----------------------------------------------------------------

server <- function(input, output, session) {
  makes <- unique(cars$make)
  names(makes) <- makes

  sd_question(
    type = "select",
    id = "make",
    label = "Make:",
    option = makes
  )

  observe({
    make_selected_df <- cars[which(sd_value("make") == cars$make), ]
    models <- make_selected_df$model
    names(models) <- models

    sd_question(
      type = "select",
      id = "model",
      label = "Model:",
      option = models
    )
  })

  # Run surveydown server and define database
  sd_server(db = db)
}

# Launch the app
shiny::shinyApp(ui = ui, server = server)