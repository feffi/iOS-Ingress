#!/bin/sh
cd Ingress
mogenerator --template-var arc=true -m Ingress.xcdatamodeld/Ingress.xcdatamodel/ -M CoreData/Machine/ -H CoreData/Human/
