from prefect import flow, task, get_run_logger

@task
def respond_to_event(triggered_by_resource, param1, param2):
    logger = get_run_logger()
    logger.info(f"Responded to some.test.event event emitted by {triggered_by_resource} with params {param1} and {param2}")


@flow(name="Acting on Event Flow")
def acting_on_event_flow(triggered_by_resource, param1, param2):
    respond_to_event(triggered_by_resource, param1, param2)


if __name__ == "__main__":
    acting_on_event_flow()
