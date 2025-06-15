import '../models/seasonal_month.dart';

class SeasonsData {
  static const List<SeasonalMonth> seasons = [
    SeasonalMonth(
      month: 1,
      title: "Site Preparation & Planting",
      shortDescription: "Prepare planting site and establish mango seedlings",
      fullInstructions: "During the first month, select a site with deep, well-drained loamy soil, full sun exposure, and protection from waterlogging and frost to promote vigorous root growth and canopy development. Dig planting pits 1 m × 1 m × 1 m at optimal spacings (10 m × 10 m in drier zones or 12 m × 12 m in richer, wet soils) to balance tree vigor and orchard floor utilization. Allow pits to \"weather\" through the first rains so they retain moisture, then backfill with the excavated soil mixed with well-decomposed farmyard manure at a 3:1 soil:FYM ratio. Remove seedlings from polybags by tearing down the side, place the graft union at soil level, half-fill the pit, water to settle the root ball, then completely fill and form a shallow basin around the trunk to conserve moisture. Finally, apply a 5 cm layer of organic mulch (rice straw, wood chips) beneath each seedling to suppress weeds, moderate soil temperature, and feed soil biota.",
      activities: [
        "Site selection and preparation",
        "Digging planting pits",
        "Soil amendment with farmyard manure",
        "Planting seedlings",
        "Mulching around trees"
      ],
    ),
    SeasonalMonth(
      month: 2,
      title: "Early Establishment & Nutrition",
      shortDescription: "Apply initial nutrition and monitor young trees",
      fullInstructions: "At three months after planting, apply 10 kg of farmyard manure per tree or 1 kg of Agape Organic fertilizer as a basal dressing, followed by 50 g each of a phosphorous and potassium rich fertilizer in two equal splits every two months to support root and shoot expansion. Incorporate crop and soil booster, notably Rebearth at planting and again in the sixth month to enhance nutrient uptake and soil health. Monitor young trees for weed competition; remove weeds by hand or light hoeing within a 1 m radius of the trunk to reduce nutrient and moisture competition and limit pest harborage.",
      activities: [
        "Application of farmyard manure or organic fertilizer",
        "Phosphorous and potassium fertilization",
        "Weed control around young trees",
        "Monitoring tree health"
      ],
    ),
    SeasonalMonth(
      month: 3,
      title: "Irrigation Scheduling",
      shortDescription: "Establish proper irrigation practices",
      fullInstructions: "As trees approach flowering, irrigate at 10- to 15-day intervals to maintain consistent soil moisture—especially critical from the time fruits reach pea size until harvest—to avoid fruit drop and ensure uniform development. Use micro-sprinklers or drip where possible to reduce water waste and foliage wetting, which can spread fungal spores. Adjust irrigation frequency based on rainfall: skip scheduled irrigations if ≥25 mm of rain has fallen in the preceding week, but resume promptly if dry spells recur.",
      activities: [
        "Setting up irrigation schedule",
        "Monitoring soil moisture",
        "Adjusting irrigation based on rainfall",
        "Maintaining irrigation equipment"
      ],
    ),
    SeasonalMonth(
      month: 4,
      title: "Flower Management & Deblossoming",
      shortDescription: "Manage flowering for better fruit set",
      fullInstructions: "To reduce malformed blooms and promote uniform flowering, remove early-emerging panicles manually using a sharp, sterile knife, targeting abnormal or excessively dense inflorescences. This \"deblossoming\" practice helps balance vegetative and reproductive growth and reduces malformation caused by mites and other pathogens. Ensure pollinator activity by placing honeybee hives around the orchard; healthy hives can double fruit set rates in open-pollinated varieties.",
      activities: [
        "Deblossoming abnormal inflorescences",
        "Monitoring flower health",
        "Introducing honeybee hives",
        "Assessing pollinator activity"
      ],
    ),
    SeasonalMonth(
      month: 5,
      title: "Sap-Sucking Pest Control",
      shortDescription: "Control mango hoppers and other sap-sucking pests",
      fullInstructions: "At full flowering and early fruit set, scout weekly for mango hopper; if populations exceed threshold (3 insects/panicle), apply dimethoate (0.5 mL/L) or monocrotophos (0.5 mL/L) with care to rotate chemistries and protect beneficial insects. Avoid broad-spectrum sprays on peak bloom days to preserve pollinators. Continue to maintain clean alkathene bands around trunks for mealybug control, reapplying grease barriers as needed to block crawler ascent.",
      activities: [
        "Scouting for mango hoppers",
        "Applying targeted insecticides when needed",
        "Maintaining trunk grease barriers",
        "Monitoring beneficial insect populations"
      ],
    ),
    SeasonalMonth(
      month: 6,
      title: "Disease Prevention - Mildew & Anthracnose",
      shortDescription: "Prevent and treat fungal diseases",
      fullInstructions: "Monitor for powdery mildew on emerging shoots and panicles; at first signs (white, powdery patches), apply Karathane (Dinocap, 1 mL/L) and repeat after 10-12 days if conditions remain humid. If anthracnose lesions appear on panicles or fruits (black spots, twig blight), spray carbendazim (2 g/L) on blooms and copper oxychloride (3 g/L) on foliage and twigs to limit pathogen spread. Maintain good canopy airflow by light pruning of crossing branches.",
      activities: [
        "Monitoring for powdery mildew and anthracnose",
        "Applying fungicides when needed",
        "Pruning for better air circulation",
        "Assessing disease pressure"
      ],
    ),
    SeasonalMonth(
      month: 7,
      title: "Fruit-Set Enhancement",
      shortDescription: "Improve fruit retention and development",
      fullInstructions: "As fruits reach pea size, spray Naphthalene Acetic Acid (NAA) at 20 ppm (2 g/100 L) to reduce physiological fruit drop and improve fruit retention. Begin foliar micronutrient applications (Zn, Cu, Mn, Fe, B) at 2 mL/L, repeating every 10-12 days through the marble stage to correct micro-nutrient deficiencies and support cell division. Continue targeted insecticide applications only when pest scouting thresholds are reached.",
      activities: [
        "Applying NAA for fruit retention",
        "Foliar micronutrient applications",
        "Monitoring fruit development",
        "Continuing pest control as needed"
      ],
    ),
    SeasonalMonth(
      month: 8,
      title: "Pest Traps & Termite Control",
      shortDescription: "Install fruit-fly traps and control termites",
      fullInstructions: "Install fruit-fly bait traps (methyl eugenol 0.1% + malathion 0.1%) at 100 traps/ha before fruits begin to color, emptying and rebaiting every 15 days to minimize larval infestation. Scout tree bases for termite activity; where observed, apply chlorpyrifos 0.2% drench (200 mL/100 L) to infested trunks to protect developing fruits and young bark tissues. Maintain weed-free basins and check irrigation lines for water pooling, which can attract pests.",
      activities: [
        "Installing fruit-fly traps",
        "Monitoring and rebaiting traps",
        "Controlling termite infestations",
        "Maintaining clean orchard floor"
      ],
    ),
    SeasonalMonth(
      month: 9,
      title: "Harvest Timing & Technique",
      shortDescription: "Harvest mature mango fruits",
      fullInstructions: "Begin harvesting 100-120 days after full bloom, once shoulders broaden and initial color break appears (green→light green or yellow near the stem), indicating physiological maturity. Hand-pick fruits with a 2-3 cm pedicel using sharpened shears or a clipping pole with attached basket to avoid latex burns and skin abrasions. Harvest in the coolest part of the day (early morning), avoid handling wet fruits, and immediately transfer to shaded, ventilated containers to minimize heat build-up and decay.",
      activities: [
        "Assessing fruit maturity",
        "Harvesting with proper technique",
        "Handling fruits carefully",
        "Proper storage after harvest"
      ],
    ),
    SeasonalMonth(
      month: 10,
      title: "Post-Harvest Pruning & Disease Control",
      shortDescription: "Prune trees and control post-harvest diseases",
      fullInstructions: "After harvest, prune dead or diseased wood 5-10 cm below live tissue and burn debris to reduce inoculum for dieback and gummosis. Spray copper oxychloride (0.3%) twice at 15-day intervals on pruned cuts and major scaffolds to protect against Botryodiplodia dieback. Clean and lubricate irrigation emitters and spray nozzles to prepare for the next season.",
      activities: [
        "Pruning dead/diseased wood",
        "Burning pruning debris",
        "Applying protective sprays",
        "Maintaining irrigation equipment"
      ],
    ),
    SeasonalMonth(
      month: 11,
      title: "Trunk Banding & Off-Season Sanitation",
      shortDescription: "Prepare trees for off-season pest protection",
      fullInstructions: "By early December, wrap trunks with 25 cm-wide alkathene sheets (400-gauge) at 30-40 cm above ground, sealing the lower edge with grease to block mealybug crawlers and scale insects. Remove fallen fruits, prune and destroy latency hosts, and flood or plough around tree bases to expose overwintering pest stages (e.g., mealybug eggs) before rains resume. Clean and service tools, ladders, and beehive equipment for the coming flowering season.",
      activities: [
        "Applying trunk bands with grease",
        "Sanitation of orchard floor",
        "Exposing overwintering pests",
        "Equipment maintenance"
      ],
    ),
    SeasonalMonth(
      month: 12,
      title: "Pre-Season Soil & Tool Preparation",
      shortDescription: "Prepare for the next growing season",
      fullInstructions: "In the final month before replanting or new pit digging, conduct comprehensive soil testing to adjust pH, EC, and nutrient imbalances; apply lime or gypsum based on soil analysis recommendations to optimize root health. Deep-rip compacted zones between tree rows and incorporate 5 t/ha of compost or green manure to rebuild organic matter and soil structure. Sharpen pruning tools, sterilize saws and shears in 70% alcohol, and stock up on agrochemicals, fertilizers, and tree bands to ensure timely interventions when the next planting (Month 1) begins.",
      activities: [
        "Soil testing and amendment",
        "Deep ripping compacted soil",
        "Adding organic matter",
        "Tool preparation and sterilization"
      ],
    ),
  ];

  static SeasonalMonth? getSeasonByMonth(int month) {
    try {
      return seasons.firstWhere((season) => season.month == month);
    } catch (e) {
      return null;
    }
  }

  static List<SeasonalMonth> getAllSeasons() {
    return List.from(seasons);
  }

  static int get totalSeasons => seasons.length;
}