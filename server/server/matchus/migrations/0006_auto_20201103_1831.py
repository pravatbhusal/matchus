# Generated by Django 3.1.2 on 2020-11-03 18:31

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('matchus', '0005_auto_20201103_1830'),
    ]

    operations = [
        migrations.AlterField(
            model_name='user',
            name='interests',
            field=models.JSONField(default=list),
        ),
        migrations.AlterField(
            model_name='user',
            name='photos',
            field=models.JSONField(default=list),
        ),
        migrations.AlterField(
            model_name='user',
            name='profilePhoto',
            field=models.CharField(default='', max_length=256),
        ),
    ]