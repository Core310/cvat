#!/bin/bash
LOG_FILE="/home/arika/cvat/tests/sequential_run.log"
echo "--- FINAL CLEAN MASTER AUDIT STARTING at $(date) ---" > $LOG_FILE

# Order from config
PATTERNS=(
    "cypress/e2e/setup/setup.js"
    "cypress/e2e/setup/setup_project.js"
    "cypress/e2e/auth_page.js"
    "cypress/e2e/features/*.js"
    "cypress/e2e/features2/*.js"
    "cypress/e2e/actions_tasks/**/*.js"
    "cypress/e2e/actions_tasks2/**/*.js"
    "cypress/e2e/actions_tasks3/**/*.js"
    "cypress/e2e/actions_tasks4/**/*.js"
    "cypress/e2e/actions_objects/**/*.js"
    "cypress/e2e/actions_objects2/**/*.js"
    "cypress/e2e/issues_prs/**/*.js"
    "cypress/e2e/issues_prs2/**/*.js"
    "cypress/e2e/actions_users/**/*.js"
    "cypress/e2e/actions_projects_models/**/*.js"
    "cypress/e2e/remove_users_tasks_projects_organizations.js"
)

cd /home/arika/cvat/tests
PROCESSED_SPECS=""

for pattern in "${PATTERNS[@]}"; do
    FILES=$(find . -path "./$pattern" -type f | sort)
    for spec in $FILES; do
        spec_clean=${spec#./}
        if [[ $PROCESSED_SPECS == *"$spec_clean"* ]]; then continue; fi
        PROCESSED_SPECS="$PROCESSED_SPECS $spec_clean"

        echo "--------------------------------------------------" >> $LOG_FILE
        echo "Auditing Spec: $spec_clean" >> $LOG_FILE
        
        # Recovery: Ensure admin user exists
        docker exec -it cvat_server python3 manage.py shell -c "from django.contrib.auth.models import User; User.objects.filter(username='admin').exists() or User.objects.create_superuser('admin', 'admin@localhost.company', '12qwaszx')" >> $LOG_FILE 2>&1
        
        # HEADLESS RUN at 1080p
        xvfb-run -a npx --yes corepack yarn@4.9.2 run cypress run \
            --browser electron \
            --spec "$spec_clean" \
            --config viewportWidth=1920,viewportHeight=1080,defaultCommandTimeout=30000,baseUrl="http://localhost:8093" \
            --env user="admin",password="12qwaszx" >> $LOG_FILE 2>&1
        
        [ $? -eq 0 ] && echo "RESULT: PASSED" >> $LOG_FILE || echo "RESULT: FAILED" >> $LOG_FILE
    done
done
