library(DiagrammeR)
library(DiagrammeRsvg)
library(rsvg)
library(magick)

# Generate the graph
do_af_model <- grViz("
digraph {
  graph [layout = dot, rankdir = LR, fontname = 'Times New Roman']

  # Define node styles explicitly to prevent inheritance issues
  node [shape = rectangle, style = filled, fontname = 'Times New Roman', fontcolor = black]

  # Core intervention
  Agroforestry [label = 'Agroforestry Intervention', fillcolor = '#A8E6A3', style='filled,rounded']

  # Estimated variables (light blue)
  node [fillcolor = lightblue, fontcolor = black, style='filled,rounded']
  Establishment [label = 'Establishment Costs']
  Maintenance [label = 'Maintenance Costs']
  Discount [label = 'Discount Rate']
  Tree_risk [label = 'Tree Risks']
  Coffee_risk [label = 'Coffee Risks']
  Maize_risk [label = 'Maize Risks']
  Crop_prices [label = 'Crop Prices']

  # Intermediate estimated variables (light blue)
  Soil_loss [label = 'Soil Loss Prevention']
  Annual_crop [label = 'Annual Crop']
  Grass_benefit [label = 'Grass Benefits']
  Tree_yield [label = 'Tree Yield']
  Coffee_yield [label = 'Coffee Yield']
  Timber_yield [label = 'Timber Yield']
  Maize_yield [label = 'Maize Yield']

  # Calculated variables (Softer Green for Better Readability)
  node [fillcolor = '#D4F4D2', fontcolor = black, style='filled,rounded']
  Total_costs [label = 'Total Costs']
  Revenue [label = 'Revenue']
  NPV [label = 'Net Present Value']

  # Relationships between variables
  Agroforestry -> Establishment [color = red]
  Agroforestry -> Maintenance [color = red]
  Agroforestry -> Soil_loss [color = '#006400']  
  Agroforestry -> Annual_crop [color = '#006400']  
  Agroforestry -> Grass_benefit [color = '#006400']
  Agroforestry -> Tree_yield [color = '#006400']
  Agroforestry -> Coffee_yield [color = '#006400']
  Agroforestry -> Timber_yield [color = '#006400']
  Agroforestry -> Maize_yield [color = '#006400']

  Establishment -> Total_costs [color = '#006400']
  Maintenance -> Total_costs [color = '#006400']
  Total_costs -> NPV [color = red]

  # Fix: Risks now correctly point to yield variables instead of Agroforestry
  Tree_risk -> Tree_yield [color = black]
  Coffee_risk -> Coffee_yield [color = black]
  Maize_risk -> Maize_yield [color = black]

  Soil_loss -> Revenue [color = '#006400']
  Annual_crop -> Revenue [color = '#006400']
  Grass_benefit -> Revenue [color = '#006400']
  Tree_yield -> Revenue [color = '#006400']
  Coffee_yield -> Revenue [color = '#006400']
  Timber_yield -> Revenue [color = '#006400']
  Maize_yield -> Revenue [color = '#006400']

  Crop_prices -> Revenue [color = '#006400']

  Revenue -> NPV [color = '#006400']
  Discount -> NPV [color = black]

  # Legend: Properly formatted to prevent black fill
  Legend [shape=plaintext, margin=0, label=<
    <TABLE BORDER='0' CELLBORDER='1' CELLSPACING='0' CELLPADDING='6' STYLE='rounded' BGCOLOR='white'>
      <TR><TD COLSPAN='2'><B>Legend</B></TD></TR>
      <TR><TD>Negative Effect</TD><TD><FONT COLOR='red'>&#8594;</FONT></TD></TR>
      <TR><TD>Positive Effect</TD><TD><FONT COLOR='#006400'>&#8594;</FONT></TD></TR>
      <TR><TD>Modulating Effect</TD><TD><FONT COLOR='black'>&#8594;</FONT></TD></TR>
    </TABLE>
  >];
  
  # Force legend to bottom by linking it invisibly to NPV
  NPV -> Legend [style=invis]

}
")

# Convert to SVG raw data
svg_raw <- export_svg(do_af_model) %>% charToRaw()  # Convert SVG to raw bytes
png_file <- "figures/do_af_model.png"


# Convert SVG to high-resolution PNG
png_image <- image_read(rsvg(svg_raw, 
                             width = 9000, # Adjust width (higher = better resolution)
                             height = 3000)) # Shorter height to match other figure

# Save the high-resolution PNG
image_write(png_image, png_file, format = "png", density = 300)  # 300 DPI for print quality
