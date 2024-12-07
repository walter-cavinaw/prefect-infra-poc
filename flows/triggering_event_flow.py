from prefect import flow, task, get_run_logger
from prefect.events import emit_event

@task
def trigger_event(event):
    logger = get_run_logger()
    logger.info(f"Emitting event {event}...")

    emit_event(event=event, resource={"prefect.resource.id": "my-triggering-resource-id"}, payload={"param1": "someParamValue", "param2": "someOtherParamValue"})


@flow(name="Triggering Event Flow")
def triggering_event_flow(event="some.test.event"):
    trigger_event(event)


if __name__ == "__main__":
    triggering_event_flow()
