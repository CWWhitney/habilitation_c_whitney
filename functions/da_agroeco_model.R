library(DiagrammeR)
library(DiagrammeRsvg)
library(rsvg)
library(magick)

da_agroeco_model <- grViz("
digraph agroecology_DA {
  
  # Node styles
  node [shape=box, style=filled, fontname=Helvetica, fontsize=14, width=2.5]

  # Decision Analysis Core
  DecisionModeling [label='Decision\\nModeling for\\nAgroecology\\nInterventions', fillcolor=darkblue, fontcolor=white]
  Complexity [label='DA for\\nAddressing\\nSystem\\nComplexity', fillcolor=royalblue, fontcolor=white]
  CompetingOptions [label='Assessing\\nCompeting\\nOptions', fillcolor=royalblue, fontcolor=white]
  Uncertainty [label='Incorporating\\nUncertainty', fillcolor=royalblue, fontcolor=white]

  # Agroecology components (darker green)
  Science [label='Agroecology\\nas Science', fillcolor=darkgreen, fontcolor=white]
  Practice [label='Agroecology\\nas Practice', fillcolor=darkgreen, fontcolor=white]
  Movement [label='Agroecology\\nas Social\\nMovement', fillcolor=darkgreen, fontcolor=white]

  # Expected Value Additions of DA (now child nodes of DA methods)
  EffectivePathways [label='Choosing\\nEffective\\nPathways', fillcolor=goldenrod, fontcolor=black]
  Scaling [label='Scaling &\\nSupporting', fillcolor=goldenrod, fontcolor=black]

  # Edges
  DecisionModeling -> Complexity
  DecisionModeling -> CompetingOptions
  DecisionModeling -> Uncertainty

  Science -> DecisionModeling
  Practice -> DecisionModeling
  Movement -> DecisionModeling

  Complexity -> EffectivePathways
  CompetingOptions -> EffectivePathways
  Uncertainty -> EffectivePathways

  Complexity -> Scaling
  CompetingOptions -> Scaling
  Uncertainty -> Scaling

  # Legend with correct order
  subgraph cluster_legend {
    label = 'Legend'; fontsize=16; color=black; style=dotted

    AgroecologyLegend [label='Agroecology\\nComponents', fillcolor=darkgreen, fontcolor=white, width=1.8]
    CoreLegend [label='Decision\\nModeling Core', fillcolor=darkblue, fontcolor=white, width=1.8]
    MethodsLegend [label='Decision\\nAnalysis Methods', fillcolor=royalblue, fontcolor=white, width=1.8]
    OutcomesLegend [label='Decision modeling\\nValue Addition', fillcolor=goldenrod, fontcolor=black, width=1.8]

    AgroecologyLegend -> CoreLegend [style=invis]
    CoreLegend -> MethodsLegend [style=invis]
    MethodsLegend -> OutcomesLegend [style=invis]
  }
}
")


# Convert to SVG raw data
svg_raw <- export_svg(da_agroeco_model) %>% charToRaw()  # Convert SVG to raw bytes
png_file <- "figures/da_agroeco_model.png"

# Set high resolution (e.g., 9000 x 3000 pixels for wider format)
png_width <- 5000   # Adjust width (higher = better resolution)
png_height <- 3000  # Shorter height to match other figures

# Convert SVG to high-resolution PNG
png_image <- image_read(rsvg(svg_raw, width = png_width, height = png_height))

# Save the high-resolution PNG
image_write(png_image, png_file, format = "png", density = 300)  # 300 DPI for print quality
