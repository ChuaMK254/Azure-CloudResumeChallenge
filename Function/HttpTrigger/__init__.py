import logging
import os
import azure.functions as func
#Table SDK for updating entity
from azure.data.tables import TableClient
from azure.data.tables import UpdateMode
from azure.data.tables import TableServiceClient
from azure.core.exceptions import ResourceNotFoundError

import json


connection_string = os.getenv("AzureWebJobsStorage")

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    # For entity
    table_client = TableClient.from_connection_string(connection_string, table_name="Table1")

    # For tables
    table_service = TableServiceClient.from_connection_string(connection_string)

    # Get list of tables
    table_names = [table.name for table in table_service.list_tables()]

    try:
        # Check if table exist, if not create table and entity
        if "Table1" not in table_names:
            table_client.create_table()

            entity = {
                "PartitionKey": "PageCounter",
                "RowKey": "HomePage",
                "count": 0
            }

            table_client.create_entity(entity=entity)
        
        # Get the entity
        ent = table_client.get_entity(partition_key="PageCounter", row_key="HomePage")

        # Update count
        ent['count'] += 1

        # Update entity
        table_client.update_entity(mode=UpdateMode.MERGE, entity=ent)

        data = {"count": ent["count"]}

        json_response = json.dumps(data)

        return func.HttpResponse(json_response, mimetype="application/json")
    
    except ResourceNotFoundError:
            return func.HttpResponse("Entity not found", status_code=404)
    
    except Exception as e:
        logging.error(f"Error updating entity: {str(e)}")
        return func.HttpResponse("Error updating the entity", status_code=500)
    
