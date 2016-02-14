This CQL does the following:

1. Create constraints on nodes, Person, Merchant and Address
2. Loads a .CSV file to a neo4j database with respective fields
3. Merges all duplicate rows for persons into one node for each person
4. Merges all duplicate rows for merchants into one node for each merchant
5. Merges all duplicate rows for addresses into one node for each person
6. Creates relationship between the person and the merchant
7. Create relationship between persons and their respective addresses
8. Create relationship when two or more persons share same address
