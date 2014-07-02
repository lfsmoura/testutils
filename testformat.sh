#!/bin/bash

testformat.py $@ | column -ts $'\t'
