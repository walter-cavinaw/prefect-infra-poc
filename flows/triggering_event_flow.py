from prefect import flow, task, get_run_logger
from prefect.events import emit_event

@task
def trigger_event(event, param1, param2):
    logger = get_run_logger()
    logger.info(f"Emitting event {event}...")

    emit_event(event=event, resource={"prefect.resource.id": "my-triggering-resource-id"}, payload={"param1": param1, "param2": param2})


@flow(name="Triggering Event Flow")
def triggering_event_flow(event="some.test.event", param1="defaultParam1", param2="defaultParam2"):
    trigger_event(event, param1, param2)


if __name__ == "__main__":
    triggering_event_flow()
