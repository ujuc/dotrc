def can(user, action):
    role = user.get("role")
    if action == "view_admin":
        return role == "admin"
    if action == "edit_article":
        return role in {"admin", "editor"}
    if action == "view_article":
        return role in {"admin", "editor", "viewer"}
    return False
