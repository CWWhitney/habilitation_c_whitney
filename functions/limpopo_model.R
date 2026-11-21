# Load necessary libraries
library(DiagrammeR)
library(DiagrammeRsvg)
library(rsvg)
library(magick)

# Create the graph
overview_graph <- grViz("
  digraph limpopo_model {
    graph [layout = dot, rankdir = LR, fontname = 'Times New Roman']

    // Define node styles
    node [shape = rectangle, style = filled, fontname = 'Times New Roman', fontcolor = black]

    // Input Variables (white background)
    node [fillcolor = white]
    Rainfall [label = 'Rainfall']
    RiverFlow [label = 'River Flow']
    EFlow [label = 'Environmental Flow (e-flow)']
    DamRelease [label = 'Dam Release']
    Scenarios [label = 'Scenarios']

    // Estimated Variables (light blue)
    node [fillcolor = lightblue]
    EffectiveRainfall [label = 'Effective Rainfall']
    CropWaterNeed [label = 'Crop Water Need']
    CropCoefficient [label = 'Crop Coefficient (kc)']
    Evapotranspiration [label = 'Evapotranspiration']
    FarmedArea [label = 'Farmed Area']

    // Intermediate Variables (light blue)
    TotalCropWaterNeed [label = 'Total Crop Water Need']
    IrrigationNeed [label = 'Irrigation Need']
    Efficiency [label = 'Efficiency']
    WaterLosses [label = 'Water Losses']
    UsableRiverFlow [label = 'Usable River Flow']

    // Final Outputs (Soft Green for Better Readability)
    node [fillcolor = '#D4F4D2']
    CropWaterGap [label = 'Crop Water Gap']

    // Define relationships between nodes
    Rainfall -> EffectiveRainfall [color = '#006400']
    EffectiveRainfall -> IrrigationNeed [color = 'red']
    Evapotranspiration -> CropWaterNeed [color = '#006400']
    CropCoefficient -> CropWaterNeed [color = '#006400']
    CropWaterNeed -> TotalCropWaterNeed [color = '#006400']
    FarmedArea -> TotalCropWaterNeed [color = '#006400']
    TotalCropWaterNeed -> IrrigationNeed [color = '#006400']

    RiverFlow -> UsableRiverFlow [color = '#006400']
    EFlow -> UsableRiverFlow [color = '#006400']
    DamRelease -> UsableRiverFlow [color = '#006400']
    UsableRiverFlow -> CropWaterGap [color = '#006400']

    Efficiency -> WaterLosses [color = red]
    WaterLosses -> IrrigationNeed [color = red]
    IrrigationNeed -> CropWaterGap [color = red]

    Scenarios -> CropWaterGap [color = black]

    // Add Legend
    Legend [shape=plaintext, margin=0, label=<
      <TABLE BORDER='0' CELLBORDER='1' CELLSPACING='0' CELLPADDING='6' STYLE='rounded' BGCOLOR='white'>
        <TR><TD COLSPAN='2'><B>Legend</B></TD></TR>
        <TR><TD>Negative Effect</TD><TD><FONT COLOR='red'>&#8594;</FONT></TD></TR>
        <TR><TD>Positive Effect</TD><TD><FONT COLOR='#006400'>&#8594;</FONT></TD></TR>
        <TR><TD>Modulating Effect</TD><TD><FONT COLOR='black'>&#8594;</FONT></TD></TR>
      </TABLE>
    >];

    CropWaterGap -> Legend [style=invis]
  }
")

# Convert to SVG raw data
svg_raw <- export_svg(overview_graph) %>% charToRaw()  
png_file <- "figures/limpopo_model.png"

# Convert SVG to high-resolution PNG
png_image <- image_read(rsvg(svg_raw, 
                             # Set high resolution
                             width = 9000, 
                             height = 3000))

# Save the high-resolution PNG
image_write(png_image, png_file, format = "png", density = 300)  
