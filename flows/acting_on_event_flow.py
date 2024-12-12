from prefect import flow, task, get_run_logger
from prefect.flow_runs import pause_flow_run

@task
def respond_to_event(triggered_by_resource, param1, param2, user):
    logger = get_run_logger()
    logger.info(f"Responded to some.test.event event emitted by {triggered_by_resource} with params {param1} and {param2}, and {user} as the user")


@flow(name="Acting on Event Flow")
def acting_on_event_flow(triggered_by_resource, param1, param2):
    user = pause_flow_run(wait_for_input=str)
    respond_to_event(triggered_by_resource, param1, param2, user)


if __name__ == "__main__":
    acting_on_event_flow()
