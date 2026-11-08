def admin_dashboard(user):
    if user.get("role") != "admin":
        return {"status": 403}
    return {"status": 200, "body": "admin"}


def edit_article(user):
    if user.get("role") not in {"admin", "editor"}:
        return {"status": 403}
    return {"status": 200, "body": "edit"}


def view_article(user):
    if user.get("role") not in {"admin", "editor", "viewer"}:
        return {"status": 403}
    return {"status": 200, "body": "view"}
