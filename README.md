# olist-ecommerce-delivery-analysis
SQL analysis of delivery performance and customer satisfaction using the Olist Brazilian E-Commerce dataset
1. **Project Overview**

This project analyzes delivery performance and customer satisfaction in the Brazilian e-commerce marketplace Olist.

1. **Business Problem**

The Operations Manager at an e-commerce marketplace wants to understand whether late deliveries are associated with lower customer satisfaction.

1. **Business Questions**

Does late delivery hurt customer reviews? Are some seller states more affected than others?

1. **Data Source**

**Dataset:** The dataset has information of 100k orders from 2016 to 2018 made at multiple marketplaces in Brazil

**Source:** https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

1. **Data Preparation**

The dataset was reviewed and prepared using SQL to support the exploratory analysis. Before conducting the analysis, I performed data quality checks to assess the reliability and consistency of the datasets.

- The dataset contains 99,441 orders.
- 96,478 orders have a delivered status.
- 2,965 orders have missing actual delivery dates. Eight of these belong to orders marked as delivered.
- No missing estimated delivery dates or purchase timestamps were found.
- No invalid delivery date sequences were identified.
- No null or out-of-range review scores were found.
- No orphan records were found between orders and order items, orders and reviews, or order items and sellers.
1. **Key Findings**

**Late Deliveries Are Associated with Lower Customer Satisfaction**

Most orders were delivered on time. However, 7,826 orders arrived after their estimated delivery dates.

Late orders received an average review score of 2.57, compared with 4.29 for on-time orders.

This represents a difference of **1.72 points** on a five-point scale.

The results show a strong negative association between late deliveries and customer satisfaction. However, this analysis does not establish causation.

**Seller States with the Lowest Review Scores for Late Deliveries**

RN recorded the lowest average review score (1.40), but the result is based on only five orders and should not be generalized.

São Paulo (SP) stands out because it combines a relatively low average review score (2.57) with a much larger volume of late orders (5,872).

**7. Project Conclusion**

The analysis reveals a strong association between delivery delays and lower customer review scores in the Olist dataset.

Although most orders were delivered on time, late deliveries received substantially lower average review scores.

At the regional level, Maranhão stands out for its late delivery rate, while São Paulo represents the largest volume of late deliveries.

These findings highlight delivery reliability as an important area for operational monitoring and further investigation.
