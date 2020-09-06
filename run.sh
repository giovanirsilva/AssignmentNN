#!/bin/sh

HOME=${ROBOT_WORK_DIR}

if [ $ROBOT_THREADS -eq 1 ]
then
    xvfb-run \
        robot \
        --outputDir $ROBOT_REPORTS_DIR \
        ${ROBOT_OPTIONS} \
        $ROBOT_TESTS_DIR
fi